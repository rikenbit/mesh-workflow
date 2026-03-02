#!/usr/bin/env python3
"""Convert MeSH XML (desc/qual) + UMLS semantic type file to ASCII .bin format.

NLM distributes MeSH data as XML from 2026 onward. This script produces the
legacy ASCII format consumed by the mesh-workflow Perl pipeline.

Usage:
    python3 mesh_xml2ascii.py \
        --desc-xml desc2025.xml \
        --qual-xml qual2025.xml \
        --umls-st umls_desc_st.txt \
        --out-desc d2025.bin \
        --out-qual q2025.bin
"""

import argparse
import sys
import xml.etree.ElementTree as ET
from collections import defaultdict

# ---------------------------------------------------------------------------
# Semantic-type name → TUID mapping (124 entries, derived from 2024 data)
# ---------------------------------------------------------------------------
SEMANTIC_TYPE_TO_TUID = {
    "Acquired Abnormality": "T020",
    "Activity": "T052",
    "Age Group": "T100",
    "Amino Acid Sequence": "T087",
    "Amino Acid, Peptide, or Protein": "T116",
    "Amphibian": "T011",
    "Anatomical Abnormality": "T190",
    "Anatomical Structure": "T017",
    "Animal": "T008",
    "Antibiotic": "T195",
    "Archaeon": "T194",
    "Bacterium": "T007",
    "Behavior": "T053",
    "Biologic Function": "T038",
    "Biologically Active Substance": "T123",
    "Biomedical Occupation or Discipline": "T091",
    "Biomedical or Dental Material": "T122",
    "Bird": "T012",
    "Body Location or Region": "T029",
    "Body Part, Organ, or Organ Component": "T023",
    "Body Space or Junction": "T030",
    "Body Substance": "T031",
    "Body System": "T022",
    "Carbohydrate Sequence": "T088",
    "Cell": "T025",
    "Cell Component": "T026",
    "Cell Function": "T043",
    "Cell or Molecular Dysfunction": "T049",
    "Chemical": "T103",
    "Chemical Viewed Functionally": "T120",
    "Chemical Viewed Structurally": "T104",
    "Classification": "T185",
    "Clinical Attribute": "T201",
    "Conceptual Entity": "T077",
    "Congenital Abnormality": "T019",
    "Daily or Recreational Activity": "T056",
    "Diagnostic Procedure": "T060",
    "Disease or Syndrome": "T047",
    "Drug Delivery Device": "T203",
    "Educational Activity": "T065",
    "Element, Ion, or Isotope": "T196",
    "Embryonic Structure": "T018",
    "Environmental Effect of Humans": "T069",
    "Enzyme": "T126",
    "Eukaryote": "T204",
    "Event": "T051",
    "Experimental Model of Disease": "T050",
    "Family Group": "T099",
    "Finding": "T033",
    "Fish": "T013",
    "Food": "T168",
    "Functional Concept": "T169",
    "Fungus": "T004",
    "Gene or Genome": "T028",
    "Genetic Function": "T045",
    "Geographic Area": "T083",
    "Governmental or Regulatory Activity": "T064",
    "Group": "T096",
    "Group Attribute": "T102",
    "Hazardous or Poisonous Substance": "T131",
    "Health Care Activity": "T058",
    "Health Care Related Organization": "T093",
    "Hormone": "T125",
    "Human": "T016",
    "Human-caused Phenomenon or Process": "T068",
    "Idea or Concept": "T078",
    "Immunologic Factor": "T129",
    "Indicator, Reagent, or Diagnostic Aid": "T130",
    "Individual Behavior": "T055",
    "Injury or Poisoning": "T037",
    "Inorganic Chemical": "T197",
    "Intellectual Product": "T170",
    "Laboratory Procedure": "T059",
    "Laboratory or Test Result": "T034",
    "Language": "T171",
    "Machine Activity": "T066",
    "Mammal": "T015",
    "Manufactured Object": "T073",
    "Medical Device": "T074",
    "Mental Process": "T041",
    "Mental or Behavioral Dysfunction": "T048",
    "Molecular Biology Research Technique": "T063",
    "Molecular Function": "T044",
    "Molecular Sequence": "T085",
    "Natural Phenomenon or Process": "T070",
    "Neoplastic Process": "T191",
    "Nucleic Acid, Nucleoside, or Nucleotide": "T114",
    "Nucleotide Sequence": "T086",
    "Occupation or Discipline": "T090",
    "Occupational Activity": "T057",
    "Organ or Tissue Function": "T042",
    "Organic Chemical": "T109",
    "Organism": "T001",
    "Organism Attribute": "T032",
    "Organism Function": "T040",
    "Organization": "T092",
    "Pathologic Function": "T046",
    "Patient or Disabled Group": "T101",
    "Pharmacologic Substance": "T121",
    "Phenomenon or Process": "T067",
    "Physical Object": "T072",
    "Physiologic Function": "T039",
    "Plant": "T002",
    "Population Group": "T098",
    "Professional Society": "T094",
    "Professional or Occupational Group": "T097",
    "Qualitative Concept": "T080",
    "Quantitative Concept": "T081",
    "Receptor": "T192",
    "Regulation or Law": "T089",
    "Reptile": "T014",
    "Research Activity": "T062",
    "Research Device": "T075",
    "Self-help or Relief Organization": "T095",
    "Sign or Symptom": "T184",
    "Social Behavior": "T054",
    "Spatial Concept": "T082",
    "Substance": "T167",
    "Temporal Concept": "T079",
    "Therapeutic or Preventive Procedure": "T061",
    "Tissue": "T024",
    "Vertebrate": "T010",
    "Virus": "T005",
    "Vitamin": "T127",
}


# ---------------------------------------------------------------------------
# Helpers
# ---------------------------------------------------------------------------

def strip_text(elem, tag):
    """Get text of a child element, stripped of leading/trailing whitespace."""
    child = elem.find(tag)
    if child is not None and child.text:
        return child.text.strip()
    return None


def format_date(elem):
    """Format a date element (with Year/Month/Day children) as YYYYMMDD."""
    if elem is None:
        return None
    y = elem.findtext("Year")
    m = elem.findtext("Month")
    d = elem.findtext("Day")
    if y and m and d:
        return f"{y}{m.zfill(2)}{d.zfill(2)}"
    return None


def format_date_short(elem):
    """Format a date element as YYMMDD (6-digit) for ENTRY pipe lines."""
    if elem is None:
        return None
    y = elem.findtext("Year")
    m = elem.findtext("Month")
    d = elem.findtext("Day")
    if y and m and d:
        return f"{y[-2:]}{m.zfill(2)}{d.zfill(2)}"
    return None


def load_semantic_types(path):
    """Load umls_desc_st.txt → {ConceptUI: [TypeName, ...]}."""
    st_map = defaultdict(list)
    with open(path) as fh:
        for line in fh:
            line = line.rstrip("\n")
            if not line:
                continue
            parts = line.split("|")
            cui = parts[0].strip()
            tname = parts[1].strip()
            if tname not in st_map[cui]:
                st_map[cui].append(tname)
    return dict(st_map)


def get_tuids(concept_ui, st_map):
    """Return list of TUIDs for a ConceptUI via UMLS lookup, sorted."""
    type_names = st_map.get(concept_ui, [])
    tuids = []
    for tn in type_names:
        tuid = SEMANTIC_TYPE_TO_TUID.get(tn)
        if tuid:
            tuids.append(tuid)
    tuids.sort()
    return tuids


def build_entry_line(term_name, tuids, lex_tag, relation, thesaurus_ids,
                     date_short, sort_ver, entry_ver):
    """Build an ENTRY pipe-delimited value with pattern code.

    Format: term_name|TUID1|TUID2|LexTag|Relation|ThesID1|ThesID2|Date|SortVer|EntryVer|pattern
    Fields are omitted when absent; the pattern code records which are present.
    """
    parts = [term_name]
    pattern = "a"

    for t in tuids:
        parts.append(t)
        pattern += "b"

    if lex_tag:
        parts.append(lex_tag)
        pattern += "c"

    if relation:
        parts.append(relation)
        pattern += "d"

    for tid in thesaurus_ids:
        parts.append(tid)
        pattern += "e"

    if date_short:
        parts.append(date_short)
        pattern += "f"

    if sort_ver:
        parts.append(sort_ver)
        pattern += "s"

    if entry_ver:
        parts.append(entry_ver)
        pattern += "v"

    parts.append(pattern)
    return "|".join(parts)


def write_field(out, tag, value):
    """Write a single 'TAG = value' line if value is non-empty."""
    if value:
        out.write(f"{tag} = {value}\n")


# ---------------------------------------------------------------------------
# Descriptor conversion
# ---------------------------------------------------------------------------

def convert_descriptors(desc_xml, umls_st_path, out_path):
    st_map = load_semantic_types(umls_st_path)
    count = 0

    with open(out_path, "w") as out:
        for event, elem in ET.iterparse(desc_xml, events=("end",)):
            if elem.tag != "DescriptorRecord":
                continue

            desc_class = elem.get("DescriptorClass", "")
            desc_ui = elem.findtext("DescriptorUI")

            # --- Locate preferred concept and preferred term -----------------
            pref_concept = None
            pref_term = None
            for concept in elem.findall(".//Concept"):
                if concept.get("PreferredConceptYN") == "Y":
                    pref_concept = concept
                    for term in concept.findall(".//Term"):
                        if (term.get("RecordPreferredTermYN") == "Y"
                                and term.get("IsPermutedTermYN") == "N"):
                            pref_term = term
                    break

            if pref_concept is None or pref_term is None:
                elem.clear()
                continue

            pref_concept_ui = pref_concept.findtext("ConceptUI")

            # --- MH (preferred heading) -------------------------------------
            mh = pref_term.findtext("String", "").strip()

            # --- DE (entry version of MH) -----------------------------------
            de = strip_text(pref_term, "EntryVersion")

            # --- AQ (allowable qualifiers, alphabetically sorted) -----------
            aq_list = []
            for aq in elem.findall(".//AllowableQualifier"):
                abbr = strip_text(aq, "Abbreviation")
                if abbr:
                    aq_list.append(abbr)
            aq_list.sort()
            aq = " ".join(aq_list) if aq_list else None

            # --- Build concept relation map for non-preferred concepts ------
            # ConceptUI → RelationName from ConceptRelationList
            concept_relation = {}
            for concept in elem.findall(".//Concept"):
                if concept.get("PreferredConceptYN") == "Y":
                    continue
                cui = concept.findtext("ConceptUI")
                # Find the ConceptRelation where this concept is Concept2UI
                for cr in concept.findall(".//ConceptRelation"):
                    rn = cr.get("RelationName", "")
                    if rn:
                        concept_relation[cui] = rn
                        break

            # --- ENTRY lines ---
            # Order: non-preferred concepts first, then preferred concept's
            # non-preferred terms; permuted terms last.
            entry_lines = []
            entry_permuted = []

            concepts = elem.findall(".//Concept")
            # Process preferred concept first (its non-record-preferred terms
            # correspond to PRINT ENTRY in original ASCII and come first),
            # then non-preferred concepts.
            pref_concepts = [c for c in concepts
                             if c.get("PreferredConceptYN") == "Y"]
            non_pref_concepts = [c for c in concepts
                                 if c.get("PreferredConceptYN") != "Y"]

            for concept in pref_concepts + non_pref_concepts:
                concept_pref = concept.get("PreferredConceptYN")
                cui = concept.findtext("ConceptUI")
                tuids = get_tuids(cui, st_map)

                for term in concept.findall(".//Term"):
                    # Skip the record preferred term (that's MH)
                    if (term.get("RecordPreferredTermYN") == "Y"
                            and term.get("IsPermutedTermYN") == "N"):
                        continue

                    term_name = term.findtext("String", "").strip()
                    is_permuted = term.get("IsPermutedTermYN") == "Y"

                    if is_permuted:
                        entry_permuted.append(term_name)
                        continue

                    # Non-permuted, non-record-preferred term → pipe format
                    lex_tag = term.get("LexicalTag", "")

                    if concept_pref == "Y":
                        relation = "EQV"
                    else:
                        relation = concept_relation.get(cui, "NRW")

                    thes_ids = [t.text.strip() for t in term.findall(".//ThesaurusID")
                                if t.text]

                    date_elem = term.find("DateCreated")
                    date_short = format_date_short(date_elem)

                    sort_ver = strip_text(term, "SortVersion")
                    entry_ver = strip_text(term, "EntryVersion")

                    line = build_entry_line(
                        term_name, tuids, lex_tag, relation,
                        thes_ids, date_short, sort_ver, entry_ver)
                    entry_lines.append(line)

            # --- MN (tree numbers) ------------------------------------------
            mn_list = [tn.text.strip() for tn in elem.findall(".//TreeNumberList/TreeNumber")
                       if tn.text]

            # --- FX (see related descriptors) --------------------------------
            fx_list = []
            for srd in elem.findall(".//SeeRelatedList/SeeRelatedDescriptor"):
                name = srd.findtext(".//DescriptorName/String", "").strip()
                if name:
                    fx_list.append(name)
            fx_list.sort()

            # --- EC (entry combinations) ------------------------------------
            ec_list = []
            for ec in elem.findall(".//EntryCombinationList/EntryCombination"):
                ecin_q = ec.findtext(".//ECIN/QualifierReferredTo/QualifierName/String", "").strip()
                ecout_d = ec.findtext(".//ECOUT/DescriptorReferredTo/DescriptorName/String", "").strip()
                ecout_q = ec.findtext(".//ECOUT/QualifierReferredTo/QualifierName/String")
                if ecin_q and ecout_d:
                    val = f"{ecin_q}:{ecout_d}"
                    if ecout_q and ecout_q.strip():
                        val += f":{ecout_q.strip()}"
                    ec_list.append(val)
            ec_list.sort()

            # --- MH_TH (thesaurus IDs of preferred term) -------------------
            mh_th_list = [t.text.strip() for t in pref_term.findall(".//ThesaurusID")
                          if t.text]

            # --- PA (pharmacological actions) --------------------------------
            pa_list = []
            for pa in elem.findall(".//PharmacologicalActionList/PharmacologicalAction"):
                name = pa.findtext(".//DescriptorName/String", "").strip()
                if name:
                    pa_list.append(name)
            pa_list.sort()

            # --- ST (semantic types via UMLS) --------------------------------
            st_list = get_tuids(pref_concept_ui, st_map)

            # --- N1 (CAS N1 name) -------------------------------------------
            n1 = strip_text(pref_concept, "CASN1Name")

            # --- RN (registry numbers, inside RegistryNumberList) ----------------
            rn_list = [r.text.strip()
                       for r in pref_concept.findall("RegistryNumberList/RegistryNumber")
                       if r.text]

            # --- RR (related registry numbers) --------------------------------
            rr_list = [r.text.strip()
                       for r in pref_concept.findall(".//RelatedRegistryNumber")
                       if r.text]

            # --- Simple text fields ------------------------------------------
            an = strip_text(elem, "Annotation")
            pi_list = [p.text.strip() for p in elem.findall(".//PreviousIndexing")
                       if p.text]
            ms = strip_text(pref_concept, "ScopeNote")
            cx = strip_text(elem, "ConsiderAlso")
            ol = strip_text(elem, "OnlineNote")
            pm = strip_text(elem, "PublicMeSHNote")
            hn = strip_text(elem, "HistoryNote")

            # --- Date fields -------------------------------------------------
            lu = format_date(elem.find("DateRevised"))
            dx = format_date(elem.find("DateEstablished"))

            # === Write record ================================================
            out.write("*NEWRECORD\n")
            write_field(out, "RECTYPE", "D")
            write_field(out, "MH", mh)
            write_field(out, "DE", de)
            write_field(out, "AQ", aq)
            for el in entry_lines:
                write_field(out, "ENTRY", el)
            entry_permuted.sort()
            for ep in entry_permuted:
                write_field(out, "ENTRY", ep)
            for mn in mn_list:
                write_field(out, "MN", mn)
            for pa in pa_list:
                write_field(out, "PA", pa)
            for fx in fx_list:
                write_field(out, "FX", fx)
            for ec in ec_list:
                write_field(out, "EC", ec)
            for th in mh_th_list:
                write_field(out, "MH_TH", th)
            for st in st_list:
                write_field(out, "ST", st)
            write_field(out, "N1", n1)
            for rn in rn_list:
                write_field(out, "RN", rn)
            for rr in rr_list:
                write_field(out, "RR", rr)
            write_field(out, "AN", an)
            write_field(out, "CX", cx)
            for pi in pi_list:
                write_field(out, "PI", pi)
            write_field(out, "MS", ms)
            write_field(out, "OL", ol)
            write_field(out, "PM", pm)
            write_field(out, "HN", hn)
            write_field(out, "LU", lu)
            write_field(out, "DC", desc_class)
            write_field(out, "DX", dx)
            write_field(out, "UI", desc_ui)
            out.write("\n")

            count += 1
            elem.clear()

    return count


# ---------------------------------------------------------------------------
# Qualifier conversion
# ---------------------------------------------------------------------------

def convert_qualifiers(qual_xml, out_path):
    tree = ET.parse(qual_xml)
    root = tree.getroot()
    count = 0

    with open(out_path, "w") as out:
        for qr in root.findall("QualifierRecord"):
            qual_ui = qr.findtext("QualifierUI")

            # Locate preferred concept and preferred term
            pref_concept = None
            pref_term = None
            for concept in qr.findall(".//Concept"):
                if concept.get("PreferredConceptYN") == "Y":
                    pref_concept = concept
                    for term in concept.findall(".//Term"):
                        if (term.get("RecordPreferredTermYN") == "Y"
                                and term.get("IsPermutedTermYN") == "N"):
                            pref_term = term
                    break

            if pref_concept is None or pref_term is None:
                continue

            sh = pref_term.findtext("String", "").strip()
            qs = strip_text(pref_term, "SortVersion")
            qe = strip_text(pref_term, "EntryVersion")
            qa = strip_text(pref_term, "Abbreviation")
            ms = strip_text(pref_concept, "ScopeNote")
            an = strip_text(qr, "Annotation")
            ol = strip_text(qr, "OnlineNote")
            hn = strip_text(qr, "HistoryNote")

            # QX: non-preferred terms with relation
            qx_list = []
            for concept in qr.findall(".//Concept"):
                if concept.get("PreferredConceptYN") == "Y":
                    # Also include non-record-preferred terms from preferred concept
                    concept_cui = concept.findtext("ConceptUI")
                    for term in concept.findall(".//Term"):
                        if term.get("RecordPreferredTermYN") == "Y":
                            continue
                        if term.get("IsPermutedTermYN") == "Y":
                            continue
                        term_name = term.findtext("String", "").strip()
                        qx_list.append(f"{term_name}|EQV")
                else:
                    # Non-preferred concept: find relation name
                    relation = ""
                    for cr in concept.findall(".//ConceptRelation"):
                        rn = cr.get("RelationName", "")
                        if rn:
                            relation = rn
                            break
                    for term in concept.findall(".//Term"):
                        if term.get("IsPermutedTermYN") == "Y":
                            continue
                        term_name = term.findtext("String", "").strip()
                        qx_list.append(f"{term_name}|{relation}")

            # Sort QX by term name (part before first pipe)
            qx_list.sort(key=lambda x: x.split("|")[0])

            lu = format_date(qr.find("DateRevised"))
            dq = format_date(qr.find("DateEstablished"))

            # Write record
            out.write("*NEWRECORD\n")
            write_field(out, "RECTYPE", "Q")
            write_field(out, "SH", sh)
            write_field(out, "QS", qs)
            write_field(out, "QE", qe)
            write_field(out, "QA", qa)
            write_field(out, "QT", "1")
            write_field(out, "MS", ms)
            write_field(out, "AN", an)
            write_field(out, "OL", ol)
            write_field(out, "HN", hn)
            for qx in qx_list:
                write_field(out, "QX", qx)
            write_field(out, "LU", lu)
            write_field(out, "DQ", dq)
            write_field(out, "UI", qual_ui)
            out.write("\n")

            count += 1

    return count


# ---------------------------------------------------------------------------
# CLI
# ---------------------------------------------------------------------------

def main():
    parser = argparse.ArgumentParser(
        description="Convert MeSH XML to ASCII .bin format")
    parser.add_argument("--desc-xml", required=True,
                        help="Path to descriptor XML (desc{year}.xml)")
    parser.add_argument("--qual-xml", required=True,
                        help="Path to qualifier XML (qual{year}.xml)")
    parser.add_argument("--umls-st", required=True,
                        help="Path to UMLS semantic type file (umls_desc_st.txt)")
    parser.add_argument("--out-desc", required=True,
                        help="Output path for descriptor ASCII (d{year}.bin)")
    parser.add_argument("--out-qual", required=True,
                        help="Output path for qualifier ASCII (q{year}.bin)")
    args = parser.parse_args()

    print(f"Converting qualifiers: {args.qual_xml}", file=sys.stderr)
    nq = convert_qualifiers(args.qual_xml, args.out_qual)
    print(f"  → {nq} qualifier records written to {args.out_qual}", file=sys.stderr)

    print(f"Converting descriptors: {args.desc_xml}", file=sys.stderr)
    nd = convert_descriptors(args.desc_xml, args.umls_st, args.out_desc)
    print(f"  → {nd} descriptor records written to {args.out_desc}", file=sys.stderr)


if __name__ == "__main__":
    main()
