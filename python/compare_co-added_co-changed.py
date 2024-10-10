from lxml import etree

def compare_nicad_xml(base_xml, compare_xml):
    parser = etree.XMLParser(recover=True)
    base_root = etree.parse(base_xml, parser=parser).getroot()
    compare_root = etree.parse(compare_xml, parser=parser).getroot()

    base_functions = {}
    compare_functions = {}

    # 解析基础版本的function
    for class_elem in base_root.findall('class'):
        for source_elem in class_elem.findall('source'):
            function_code = ''.join(source_elem.itertext())
            base_functions[function_code] = True

    # 解析比较版本的function
    for class_elem in compare_root.findall('class'):
        for source_elem in class_elem.findall('source'):
            function_code = ''.join(source_elem.itertext())
            compare_functions[function_code] = True

    new_functions_count = 0
    modified_functions_count = 0
    deleted_functions_count = 0

    # 计算新增和修改的function数量
    for function_code in compare_functions:
        if function_code not in base_functions:
            new_functions_count += 1
        else:
            base_functions.pop(function_code)


    # 修改的function数量等于基础版本中剩余的function数量
    modified_functions_count = len(base_functions)

    return new_functions_count, modified_functions_count, deleted_functions_count

# 示例用法
base_xml = r'D:\program\solidity-nicad-master\openzeppelin\openzeppelin-solidity-v4.6.0\withsource\type-3-2.xml'
compare_xml = r'D:\program\solidity-nicad-master\openzeppelin\openzeppelin-solidity-v4.7.0\withsource\type-3-2.xml'
new_funcs_count, modified_funcs_count, deleted_funcs_count = compare_nicad_xml(base_xml, compare_xml)

print(f"新增的function数量: {new_funcs_count}")
print(f"修改的function数量: {modified_funcs_count}")