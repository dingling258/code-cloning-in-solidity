import os
from lxml import etree

def get_sol_files(path):
    sol_files = []
    for root, dirs, files in os.walk(path):
        for file in files:
            if file.endswith(".sol"):
                sol_files.append(os.path.join(root, file))
    return sol_files

def extract_functions(file_path):
    functions = []
    with open(file_path, "r", encoding="utf-8") as f:
        lines = f.readlines()
        for i, line in enumerate(lines):
            if line.strip().startswith("function"):
                func_name = line.split("(")[0].strip().split(" ")[-1]
                functions.append((os.path.basename(file_path), func_name, i + 1))
    return functions

def compare_functions(base_folder, compare_folder):
    base_files = get_sol_files(base_folder)
    compare_files = get_sol_files(compare_folder)

    base_functions = set()
    for file in base_files:
        base_functions.update(extract_functions(file))

    compare_functions = set()
    for file in compare_files:
        compare_functions.update(extract_functions(file))

    new_functions = compare_functions - base_functions
    return new_functions

def get_clone_classes(xml_file):
    parser = etree.XMLParser(recover=True)
    root = etree.parse(xml_file, parser=parser).getroot()

    clone_classes = []
    for class_elem in root.findall('class'):
        clone_class = []
        for source_elem in class_elem.findall('source'):
            file = os.path.basename(source_elem.get('file'))
            startline = int(source_elem.get('startline'))
            endline = int(source_elem.get('endline'))
            clone_class.append((file, startline, endline))
        clone_classes.append(clone_class)

    return clone_classes

def calculate_co_added_functions(new_functions, base_classes, compare_classes):
    co_added = set()
    for compare_class in compare_classes:
        if compare_class not in base_classes:
            matching_base_class = next((bc for bc in base_classes if any(f in bc for f in compare_class)), None)
            if matching_base_class:
                new_in_class = [f for f in compare_class if f not in matching_base_class]
            else:
                new_in_class = compare_class

            for file, start, end in new_in_class:
                for func in new_functions:
                    if func[0] == file and start <= func[2] <= end:
                        co_added.add(func)

    return co_added

def get_function_identifier(source_elem):
    function_name = source_elem.get('name', '')
    file_name = source_elem.get('file', '')
    return f"{file_name}:{function_name}"

def get_function_content(source_elem):
    return ''.join(source_elem.itertext()).strip()

def compare_nicad_xml(base_xml, compare_xml):
    parser = etree.XMLParser(recover=True)
    base_root = etree.parse(base_xml, parser=parser).getroot()
    compare_root = etree.parse(compare_xml, parser=parser).getroot()

    base_clones = {}
    compare_clones = {}

    for class_elem in base_root.findall('class'):
        clone_id = class_elem.get('classid')
        base_clones[clone_id] = {
            get_function_identifier(source_elem): get_function_content(source_elem)
            for source_elem in class_elem.findall('source')
        }

    for class_elem in compare_root.findall('class'):
        clone_id = class_elem.get('classid')
        compare_clones[clone_id] = {
            get_function_identifier(source_elem): get_function_content(source_elem)
            for source_elem in class_elem.findall('source')
        }

    co_changed_count = 0

    for clone_id, base_functions in base_clones.items():
        if clone_id in compare_clones:
            compare_functions = compare_clones[clone_id]
            for func_id, base_content in base_functions.items():
                if func_id in compare_functions:
                    compare_content = compare_functions[func_id]
                    if base_content != compare_content:
                        co_changed_count += 1

    return co_changed_count

def get_cloned_functions(xml_file):
    parser = etree.XMLParser(recover=True)
    root = etree.parse(xml_file, parser=parser).getroot()
    cloned_functions = {}

    for class_elem in root.findall('class'):
        class_id = class_elem.get('classid')
        functions = set()
        for source_elem in class_elem.findall('source'):
            file_name = source_elem.get('file', '')
            func_name = source_elem.get('startline', '').split()[-1]
            functions.add(f"{file_name}:{func_name}")
        cloned_functions[class_id] = functions

    return cloned_functions

def get_all_functions(folder_path):
    all_functions = set()
    for root, dirs, files in os.walk(folder_path):
        for file in files:
            if file.endswith(".sol"):
                file_path = os.path.join(root, file)
                functions = extract_functions(file_path)
                all_functions.update(f"{file}:{func[1]}" for func in functions)
    return all_functions

def compare_clones(base_folder, compare_folder, base_xml, compare_xml):
    base_clones = get_cloned_functions(base_xml)
    compare_clones = get_cloned_functions(compare_xml)

    base_all_functions = get_all_functions(base_folder)
    compare_all_functions = get_all_functions(compare_folder)

    co_deleted_count = 0

    for class_id, base_functions in base_clones.items():
        if class_id not in compare_clones:
            co_deleted_count += len(base_functions)
        else:
            compare_functions = compare_clones[class_id]
            deleted_functions = base_functions - compare_functions

            real_deleted = [func for func in deleted_functions if func not in compare_all_functions]

            if len(real_deleted) > 0:
                co_deleted_count += len(real_deleted)

    return co_deleted_count

def main():
    base_folder = r'D:\program\solidity-nicad-master\synthetix\v2.53.0\source-code'
    compare_folder = r'D:\program\solidity-nicad-master\synthetix\v2.54.0\source-code'
    base_xml = r'D:\program\solidity-nicad-master\synthetix\v2.53.0\withsource\type-3-2.xml'
    compare_xml = r'D:\program\solidity-nicad-master\synthetix\v2.54.0\withsource\type-3-2.xml'

    new_functions = compare_functions(base_folder, compare_folder)
    base_classes = get_clone_classes(base_xml)
    compare_classes = get_clone_classes(compare_xml)
    co_added_functions = calculate_co_added_functions(new_functions, base_classes, compare_classes)
    co_changed_funcs_count = compare_nicad_xml(base_xml, compare_xml)
    co_deleted_count = compare_clones(base_folder, compare_folder, base_xml, compare_xml)

    print(f"新增的function数量: {len(new_functions)}")
    print(f"Co-added functions数量: {len(co_added_functions)}")
    print(f"Co-changed functions数量: {co_changed_funcs_count}")
    print(f"Co-deleted functions数量: {co_deleted_count}")


if __name__ == "__main__":
    main()