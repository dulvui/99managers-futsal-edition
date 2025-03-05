import polib
import argparse

def load_po_dict(po_file):
    """Load a .po file into a dictionary mapping msgid to msgstr."""
    po = polib.pofile(po_file)
    return {entry.msgid: entry.msgstr for entry in po if entry.msgstr}

def load_pot_ids(pot_file):
    """Load a .pot file into a dictionary mapping msgid (IDs) to themselves."""
    pot = polib.pofile(pot_file)
    return {entry.msgid: entry.msgid for entry in pot}

def convert_po(old_pot, old_en_po, new_pot, input_po, output_po, unmatched_file):
    """Convert a .po file from using IDs to plain English msgid."""
    
    # Load old .pot (ID-based) and corresponding en.po (ID -> English mappings)
    id_to_en = load_po_dict(old_en_po)
    id_list = load_pot_ids(old_pot)
    
    # Reverse map to get English -> ID
    en_to_id = {v: k for k, v in id_to_en.items() if v}
    
    # Load the new .pot (which uses English msgid)
    new_pot_entries = load_pot_ids(new_pot)
    
    # Load the input .po file to translate
    input_entries = load_po_dict(input_po)
    
    new_po = polib.POFile()
    unmatched = []
    
    for english_msgid in new_pot_entries.keys():
        old_id = en_to_id.get(english_msgid)
        if old_id and old_id in input_entries:
            translation = input_entries[old_id]
        else:
            translation = ""  # No translation found
            unmatched.append(english_msgid)
        
        entry = polib.POEntry(msgid=english_msgid, msgstr=translation)
        new_po.append(entry)
    
    new_po.save(output_po)
    
    with open(unmatched_file, "w", encoding="utf-8") as f:
        for msgid in unmatched:
            f.write(msgid + "\n")
    
    print(f"Converted {input_po} -> {output_po}")
    print(f"Unmatched msgids saved to {unmatched_file}")

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Convert .po files from ID-based msgid to plain English msgid.")
    parser.add_argument("--old_pot", required=True, help="Path to old .pot file using IDs.")
    parser.add_argument("--old_en_po", required=True, help="Path to old en.po file with English translations.")
    parser.add_argument("--new_pot", required=True, help="Path to new .pot file using English msgid.")
    parser.add_argument("--input_po", required=True, help="Path to input .po file using IDs.")
    parser.add_argument("--output_po", required=True, help="Path to save the new converted .po file.")
    parser.add_argument("--unmatched_file", required=True, help="Path to save unmatched msgids.")
    
    args = parser.parse_args()
    
    convert_po(args.old_pot, args.old_en_po, args.new_pot, args.input_po, args.output_po, args.unmatched_file)

