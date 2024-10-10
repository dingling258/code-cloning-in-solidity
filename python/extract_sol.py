import os
import shutil


def extract_and_cleanup_sol_files(version_dir):
    # 遍历指定文件夹中所有文件和子文件夹
    for root, dirs, files in os.walk(version_dir):
        for file in files:
            if file.endswith('.sol'):
                # 构建完整的文件路径
                file_path = os.path.join(root, file)
                # 如果文件不在根目录，移动到根目录
                if root != version_dir:
                    shutil.move(file_path, version_dir)
            else:
                # 删除非 .sol 文件
                os.remove(os.path.join(root, file))

    # 删除所有空的子文件夹
    for root, dirs, files in os.walk(version_dir, topdown=False):
        for dir in dirs:
            dir_path = os.path.join(root, dir)
            if not os.listdir(dir_path):
                os.rmdir(dir_path)

    print(f"处理完成：{version_dir}")


# 基础目录
base_dir = r'D:\program\solidity-nicad-master\Uniswap'

# 遍历基础目录下的所有子文件夹（每个代表一个版本）
for version in next(os.walk(base_dir))[1]:  # next(os.walk(base_dir))[1] 获取所有子目录名称
    version_dir = os.path.join(base_dir, version)
    extract_and_cleanup_sol_files(version_dir)