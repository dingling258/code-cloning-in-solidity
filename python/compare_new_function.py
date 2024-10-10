import os

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
        for i in range(len(lines)):
            if lines[i].strip().startswith("function"):
                func_name = lines[i].split("(")[0].strip().split(" ")[-1]
                func_code = [lines[i].strip()]
                j = i + 1
                while j < len(lines) and not lines[j].strip().startswith("}"):
                    func_code.append(lines[j].strip())
                    j += 1
                functions.append((func_name, "\n".join(func_code)))
    return functions


def compare_functions(base_folder, compare_folder):
    base_files = get_sol_files(base_folder)
    compare_files = get_sol_files(compare_folder)

    new_functions = 0
    for compare_file in compare_files:
        file_name = os.path.basename(compare_file)
        base_file = next((f for f in base_files if os.path.basename(f) == file_name), None)

        compare_funcs = extract_functions(compare_file)
        if base_file:
            base_funcs = extract_functions(base_file)
            for compare_func in compare_funcs:
                if compare_func not in base_funcs:
                    new_functions += 1
        else:
            new_functions += len(compare_funcs)

    return new_functions


base_folder = r'D:\program\solidity-nicad-master\openzeppelin\openzeppelin-solidity-v4.9.6\source-code'
compare_folder = r'D:\program\solidity-nicad-master\openzeppelin\openzeppelin-solidity-v5.0.2\source-code'
new_func_count = compare_functions(base_folder, compare_folder)
print(f"新增的function数量: {new_func_count}")