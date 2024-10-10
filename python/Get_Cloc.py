import os
from lxml import etree


def calculate_clone_statistics(xml_file):
    # 解析 XML 文件
    tree = etree.parse(xml_file)
    root = tree.getroot()

    total_clone_lines = 0
    total_clones = 0

    # 遍历所有的 <class> 元素
    for class_element in root.findall('class'):
        nclones = int(class_element.get('nclones'))
        nlines = int(class_element.get('nlines'))

        # 累加 nclones 和计算当前类的克隆行数并累加到总数
        total_clones += nclones
        total_clone_lines += nclones * nlines

    return total_clone_lines, total_clones


def process_all_xml_files(directory):
    # 列出目录中的所有文件
    files = os.listdir(directory)
    total_clone_lines_list = []
    total_clones_list = []

    # 遍历文件
    for file in files:
        if file.endswith('.xml'):
            file_path = os.path.join(directory, file)
            total_clone_lines, total_clones = calculate_clone_statistics(file_path)
            total_clone_lines_list.append(total_clone_lines)
            total_clones_list.append(total_clones)

    # 获取最大的克隆行数
    max_clone_lines = max(total_clone_lines_list)

    # 排序克隆实例总数
    total_clones_list.sort()
    clones_differences = [total_clones_list[0]] + [total_clones_list[i] - total_clones_list[i - 1] for i in
                                                   range(1, len(total_clones_list))]

    return max_clone_lines, clones_differences


# 指定文件夹路径
directory = r'D:\program\solidity-nicad-master\solidity-nicad-master\output\clonedata\raw\withoutsource'
max_clone_lines, clones_differences = process_all_xml_files(directory)

print("Maximum total clone lines:", max_clone_lines)
print("Total clones ordered and differences:", clones_differences)