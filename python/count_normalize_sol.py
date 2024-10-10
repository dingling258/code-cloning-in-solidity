import os

def count_normalized_lines(filename):
    total_lines = 0
    in_multiline_comment = False
    with open(filename, 'r', encoding='utf-8') as file:
        for line in file:
            stripped_line = line.strip()
            if in_multiline_comment:
                if '*/' in stripped_line:
                    in_multiline_comment = False
                    post_comment = stripped_line.split('*/', 1)[1].strip()
                    if post_comment and not post_comment.startswith('//'):
                        total_lines += 1
                continue
            elif stripped_line.startswith('/*'):
                in_multiline_comment = True
                if '*/' in stripped_line:
                    in_multiline_comment = False
                    post_comment = stripped_line.split('*/', 1)[1].strip()
                    if post_comment and not post_comment.startswith('//'):
                        total_lines += 1
                continue
            elif stripped_line.startswith('//'):
                continue

            if stripped_line:
                total_lines += 1
    return total_lines

def total_normalized_lines_in_folder(folder_path):
    """
    Walk through all files in the folder_path and sum up all normalized lines in .sol files.
    """
    total_lines = 0
    for root, dirs, files in os.walk(folder_path):
        for file in files:
            if file.endswith('.sol'):
                file_path = os.path.join(root, file)
                total_lines += count_normalized_lines(file_path)
    return total_lines

folder_path = r'D:\program\solidity-nicad-master\Uniswap\v4-core-main\source-code'
print("Total normalized LOC in .sol files:", total_normalized_lines_in_folder(folder_path))