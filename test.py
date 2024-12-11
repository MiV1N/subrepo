import unittest
import subprocess

from pathlib import Path

def path_exists(path):
    _path = Path(path)
    return _path.exists()

def file_contains_line(file_path, search_string):
    try:
        with open(file_path, 'r', encoding='utf-8') as file:  # 确保使用正确的编码打开文件
            for line in file:
                if search_string in line:
                    return True
    except FileNotFoundError:
        print(f"The file {file_path} does not exist.")
    except IOError:
        print(f"An I/O error occurred while reading {file_path}.")
    return False

def run(command):
    subprocess.run(command, shell=True,check=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True, encoding='utf-8' )

def del_path(path):
    _path = Path(path)
    # 检查路径是否存在
    if _path.exists():
        if _path.is_file():
            # 如果是文件，则删除
            _path.unlink()
        elif _path.is_dir():
            # 如果是文件夹，则删除
            if path != "/":
                run(f"rm -rf  {path}")
            else:
                print("error del /")

class TestCaseSubrepo(unittest.TestCase):

    def setUp(self) -> None:  # 调用setUp
        super().setUp()
        del_path('.gitignore')
        del_path('.gitsubrepo')

    def tearDown(self) -> None:  # 调用tearDown
        super().tearDown()
        del_path('.gitignore')
        del_path('.gitsubrepo')

    def test_subrepo_add_one(self):
        entry = "my_subrepo"
        url = "https://github.com/MiV1N/subrepo.git"

        gitignore_path = ".gitignore"
        gitsubrepo_path = ".gitsubrepo"
        # 使用 subprocess.run 来执行脚本
        command = f"bash subrepo.sh add {url} {entry}"
        run(command)

        # 检查是否生成文件
        self.assertTrue(path_exists(gitignore_path))
        self.assertTrue(path_exists(gitsubrepo_path))
        # 检查文件内容是否正确
        self.assertTrue(file_contains_line(gitignore_path,entry))

        self.assertTrue(file_contains_line(gitsubrepo_path,entry))
        self.assertTrue(file_contains_line(gitsubrepo_path,url))

    def test_subrepo_del_after_add(self):
        entry = "my_subrepo"
        url = "https://github.com/MiV1N/subrepo.git"

        gitignore_path = ".gitignore"
        gitsubrepo_path = ".gitsubrepo"
        # 使用 subprocess.run 来执行脚本
        run(f"bash subrepo.sh add {url} {entry}")
        run(f"bash subrepo.sh del {entry}")

        # 检查是否存在文件
        self.assertTrue(path_exists(gitignore_path))
        self.assertTrue(path_exists(gitsubrepo_path))
        # 检查文件内容是否正确
        self.assertFalse(file_contains_line(gitignore_path,entry))

        self.assertFalse(file_contains_line(gitsubrepo_path,entry))
        self.assertFalse(file_contains_line(gitsubrepo_path,url))
    
    def test_subrepo_init(self):
        entry = "my_subrepo"
        url = "https://github.com/MiV1N/subrepo.git"

        gitignore_path = ".gitignore"
        gitsubrepo_path = ".gitsubrepo"
        # 使用 subprocess.run 来执行脚本
        run(f"bash subrepo.sh add {url} {entry}")
        run(f"bash subrepo.sh init {entry}")

        # 检查是否存在文件
        self.assertTrue(path_exists(gitignore_path))
        self.assertTrue(path_exists(gitsubrepo_path))
        self.assertTrue(path_exists(entry + "/.git"))

        # 清理结果
        del_path(entry)

    def test_subrepo_del_after_init(self):
        entry = "my_subrepo"
        url = "https://github.com/MiV1N/subrepo.git"

        gitignore_path = ".gitignore"
        gitsubrepo_path = ".gitsubrepo"
        # 使用 subprocess.run 来执行脚本
        run(f"bash subrepo.sh add {url} {entry}")
        run(f"bash subrepo.sh init {entry}")
        run(f"bash subrepo.sh del {entry}")

        # 检查是否存在文件
        self.assertTrue(path_exists(gitignore_path))
        self.assertTrue(path_exists(gitsubrepo_path))
        # 检查文件内容是否正确
        self.assertFalse(file_contains_line(gitignore_path,entry))

        self.assertFalse(file_contains_line(gitsubrepo_path,entry))
        self.assertFalse(file_contains_line(gitsubrepo_path,url))
    
    # def testassertdemo_1(self):
    #     self.assertDictEqual({"code": 1}, {"code": 1})
    #     self.assertListEqual([1, 2], [1, 2])
    #     self.assertMultiLineEqual("name", "name")

    # def testassertdemo_2(self):
        # self.assertIn(1, [1, 2,3])
        # self.assertNotIn(1, [2, 3,4])
        # self.assertEqual('1', '1')
        # self.assertNotEqual(1, 2)
    #     self.assertGreater(2, 0)
    #     self.assertGreaterEqual(2, 0)
    #     self.assertNotRegex("1", "122")  # 正则是否匹配
    #     self.assertCountEqual("12", "12")
        
def suite():
    # 创建一个测试套件
    suite = unittest.TestSuite()
    # 将测试用例加载到测试套件中
    # 创建一个用例加载对象
    loader = unittest.TestLoader()
    suite.addTest(loader.loadTestsFromTestCase(TestCaseSubrepo))
    
    return suite

if __name__ == '__main__':
    runner = unittest.TextTestRunner(verbosity=2)
    runner.run(suite())