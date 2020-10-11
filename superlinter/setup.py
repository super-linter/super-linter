from setuptools import setup

setup(name='superlinter',
      version='0.1',
      description='Super-Linter',
      url='http://github.com/github/super-linter',
      author='Lukas Gravley and Nicolas Vuillamy',
      author_email='nicolas.vuillamy@gmail.com',
      license='MIT',
      packages=['superlinter'],
      install_requires=[
          'gitpython',
          'jsonschema',
          'pygithub',
          'pytablewriter',
          'pytest-cov',
          'pyyaml',
          'requests',
          'terminaltables',
          'yq'
      ],
      zip_safe=False)
