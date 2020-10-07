<!-- markdownlint-disable -->
# Super-Linter descriptor

_Descriptor definition for super-linter_

**_Properties_**

 - <b id="#http://github.com/nvuillam/superlinter.json/properties/descriptor_id">descriptor_id</b>
	 - Descriptor unique identifier
	 - _Uppercase unique identifier for the language, tooling format or identifier_
	 - Type: `string`
	 - Example values: 
		 1. _"PYTHON"_
		 2. _"XML"_
		 3. _"OPENAPI"_
		 
 - <b id="#http://github.com/nvuillam/superlinter.json/properties/descriptor_type">descriptor_type</b>
	 - Descriptor type
	 - _Descriptor type: language, format or tooling format_
	 - Type: `string`
	 - Example values: 
		 1. _"language"_
		 2. _"format"_
		 3. _"tooling_format"_
	 - The value is restricted to the following: 
		 1. _"language"_
		 2. _"format"_
		 3. _"tooling_format"_

 - <b id="#http://github.com/nvuillam/superlinter.json/properties/file_extensions">file_extensions</b>
	 - List of file extensions catch by the descriptor
	 - _File extension filters. Can be overridden at linter level_
	 - Type: `array`
	 - Example values: 
		 1. `.py`
	 - Default: ``
		 - **_Items_**
		 - Type: `string`
- <b id="#http://github.com/nvuillam/superlinter.json/properties/file_names">file_names</b>
	 - List of file names catch by the descriptor
	 - _File name filter. Can be overridden at linter level_
	 - Type: `array`
	 - Example values: 
		 1. `Dockerfile`
		 2. `Jenkinsfile`
	 - Default: ``
		 - **_Items_**
		 - Type: `string`

- <b id="#http://github.com/nvuillam/superlinter.json/properties/file_contains">file_contains</b>
	 - File content filters
	 - _List of strings or regular expressions to filter the files according to their content_
	 - Type: `array`
	 - Example values: 
		 1. `AWSTemplateFormatVersion`
		 2. `(AWS|Alexa|Custom)::`
	 - Default: ``
		 - **_Items_**
		 - Type: `string`

- <b id="#http://github.com/nvuillam/superlinter.json/properties/files_sub_directory">files_sub_directory</b>
	 - Files sub-directory
	 - _Set when a linter only lints a sub-directory_
	 - Type: `string`
	 - Example values: 
		 1. `ansible`
		 2. `kubernetes`

 - <b id="#http://github.com/nvuillam/superlinter.json/properties/files_names_not_ends_with">files_names_not_ends_with</b>
	 - Filter on end of file name
	 - _List of strings to filter the files according to their end of file name_
	 - Type: `array`
	 - Example values: 
		 1. `vault.yml`
		 2. `galaxy.xml`
	 - Default: ``
		 - **_Items_**
		 - Type: `string`

- <b id="#http://github.com/nvuillam/superlinter.json/properties/test_folder">test_folder</b>
	 - Test folder in .automation/
	 - _Test folder containing _good_ and _bad_ files. Default: lowercase(descriptor_id)_
	 - Type: `string`
	 - Example values: 
		 1. `bash_shfmt`
		 2. `terraform_terrascan`

 - <b id="#http://github.com/nvuillam/superlinter.json/properties/linters">linters</b> `required`
	 - List of linters 
	 - _List of linter definitions associated to the descriptor_
	 - Type: `array`
		 - **_Items_**
		 - **Linter definition**
		 - _Parameters defining behaviour and installation of a linter_
		 - Type: `object`
		 - **_Properties_**
			 - <b id="/properties/linters/items/properties/linter_name">linter_name</b> `required`
				 - Linter name
				 - _Name of the linter (same as cli command if possible)_
				 - Type: `string`
				 - Example values: 
					 1. _"eslint"_
			 - <b id="/properties/linters/items/properties/name">name</b>
				 - Linter configuration key
				 - _When several linters in a descriptor, set a different name that will be used for configuration_
				 - Type: `string`
				 - Example values: 
					 1. _"JAVASCRIPT_ES"_
			 - <b id="/properties/linters/items/properties/linter_url">linter_url</b> `required`
				 - Linter URL
				 - _URL of the linter home page_
				 - Type: `string`
				 - Example values: 
					 1. _"https://eslint.org"_
			 - <b id="/properties/linters/items/properties/linter_banner_image_url">linter_banner_image_url</b>
				 - Linter banner image URL
				 - _URL of an image used to build header of linter Markdown documentation_
				 - Type: `string`
				 - Example values: 
					 1. _"https://github.com/stylelint/stylelint/raw/master/identity/stylelint-icon-and-text-white.png"_
			 - <b id="/properties/linters/items/properties/linter_image_url">linter_image_url</b>
				 - Linter image URL
				 - _URL of an image used in linter Markdown documentation_
				 - Type: `string`
				 - Example values: 
					 1. _"https://raku.org/camelia-logo.png"_
			 - <b id="/properties/linters/items/properties/config_file_name">config_file_name</b>
				 - Default file name for the linter configuration file
				 - _An explanation about the purpose of this instance._
				 - Type: `string`
				 - Example values: 
					 1. _".eslintrc.yml"_
					 2. _".markdown-lint.yml"_
					 3. _".python-black"_
			 - <b id="/properties/linters/items/properties/cli_config_extra_args">cli_config_extra_args</b>
				 - Additional CLI arguments when config file is used
				 - _When a configuration file is used with the linter CLI, send these additional arguments_
				 - Type: `array`
				 - Example values: 
					 1. `--no-eslintrc`
					 2. `--no-ignore`
				 - Default: ``
					 - **_Items_**
					 - Type: `string`
			 - <b id="/properties/linters/items/properties/examples">examples</b> `required`
				 - Linter CLI commands examples
				 - _Please add an example with and without configuration file in the command. They will appear in documentation_
				 - Type: `array`
				 - Example values: 
					 1. `golangci-lint run myfile.go,golangci-lint run -c .golangci.yml myfile.go`
					 2. `eslint myfile.js,eslint -c .eslintrc.yml --no-eslintrc --no-ignore myfile.js`
					 - **_Items_**
					 - Type: `string`
			 - <b id="/properties/linters/items/properties/install">install</b> `required`
				 - Installation requirements
				 - _List of apk, dockerfile instructions, npm/pip/gem packages required to install the linter_
				 - Type: `object`
				 - **_Properties_**
					 - <b id="/properties/linters/items/properties/install/properties/dockerfile">dockerfile</b>
						 - List of Dockerfile instructions packages
						 - _Will be automatically integrated in generated Dockerfile_
						 - Type: `array`
						 - Example values: 
							 1. `FROM accurics/terrascan:d182f1c as terrascan`
							 2. `COPY --from=terrascan /go/bin/terrascan /usr/bin/`
							 3. `RUN terrascan init`
							 - **_Items_**
							 - Type: `string`
					 - <b id="/properties/linters/items/properties/install/properties/apk">apk</b>
						 - List of APK packages (Linux)
						 - _APK packages identifiers (with or without version)_
						 - Type: `array`
						 - Example values: 
							 1. `perl`
							 2. `perl-dev`
							 - **_Items_**
							 - Type: `string`
					 - <b id="/properties/linters/items/properties/install/properties/npm">npm</b>
						 - List of NPM packages (Node.js)
						 - _NPM packages identifiers (with or without version)_
						 - Type: `array`
						 - Example values: 
							 1. `eslint`
							 2. `eslint-config-airbnb@3.2.1`
							 - **_Items_**
							 - Type: `string`
					 - <b id="/properties/linters/items/properties/install/properties/gem">gem</b>
						 - List of GEM packages (Ruby)
						 - _GEM packages identifiers (with or without version)_
						 - Type: `array`
						 - Example values: 
							 1. `rubocop:0.82.0`
							 2. `rubocop-github:0.16.0`
							 3. `rubocop-performance`
							 - **_Items_**
							 - Type: `string`
					 - <b id="/properties/linters/items/properties/install/properties/pip">pip</b>
						 - List of PIP packages (Python)
						 - _PIP packages identifiers (with or without version)_
						 - Type: `array`
						 - Example values: 
							 1. `flake8`
							 - **_Items_**
							 - Type: `string`
