import os

def find_godot_files(root_dir, exclusions, project_file):
    godot_files = []
    
    for dirpath, dirnames, filenames in os.walk(root_dir):
        # Exclude entire directories
        if any(os.path.abspath(dirpath).startswith(os.path.abspath(excl)) for excl in exclusions):
            continue
        
        for file in filenames:
            file_path = os.path.join(dirpath, file)
            # Exclude specific files
            if file_path in exclusions:
                continue
            if file.endswith(('.tscn', '.gd')):
                godot_files.append(file_path.replace('../../game/', 'res://'))
    
    # Read the existing project file
    with open(project_file, 'r') as f:
        lines = f.readlines()
    
    # Clear and replace the existing array
    with open(project_file, 'w') as f:
        for line in lines:
            if line.strip().startswith("locale/translations_pot_files=PackedStringArray("):
                f.write("locale/translations_pot_files=PackedStringArray()\n")
        
        f.write(f"locale/translations_pot_files=PackedStringArray({', '.join(repr(file) for file in godot_files)})\n")
    
    print(f"Updated {project_file} with {len(godot_files)} files.")

if __name__ == "__main__":
    root_directory = "../../game/"  # Change this to your root directory
    exclusions = ["../../game/src/media"]  # Add directories or files to exclude
    project_godot_file = "../../game/project.godot"  # Path to the existing project.godot file
    
    find_godot_files(root_directory, exclusions, project_godot_file)

