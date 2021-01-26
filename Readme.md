Super-Linter
Este repositorio es para que GitHub Action ejecute un Super-Linter . Es una combinación simple de varios linters, escritos bash, para ayudar a validar su código fuente.

El objetivo final de esta herramienta:

Evite que el código roto se cargue en la rama predeterminada ( generalmente master o main)
Ayude a establecer las mejores prácticas de codificación en varios idiomas
Cree pautas para el diseño y el formato del código
Automatice el proceso para ayudar a optimizar las revisiones de código
Tabla de contenido
Super-Linter
Tabla de contenido
Cómo funciona
Linters compatibles
Cómo utilizar
Ejemplo de conexión de flujo de trabajo de acción de GitHub
Agregue la insignia Super-Linter en su repositorio README
Variables de entorno
Archivos de reglas de plantilla
Usando sus propios archivos de reglas
Deshabilitar reglas
Filtrar archivos con pelusa
Docker Hub
Ejecute Super-Linter fuera de las acciones de GitHub
Local (resolución de problemas / depuración / mejoras)
Azur
GitLab
Código de Visual Studio
Limitaciones
Cómo contribuir
Licencia
Cómo funciona
El superlinter encuentra problemas y los informa a la salida de la consola. Se sugieren correcciones en la salida de la consola, pero no se corrigen automáticamente, y una verificación de estado se mostrará como fallida en la solicitud de extracción.

Actualmente, el diseño de Super-Linter permite que se produzca la creación de líneas en las acciones de GitHub como parte de la integración continua que se produce en las solicitudes de extracción a medida que se envían las confirmaciones. Funciona mejor cuando las confirmaciones se envían temprano y, a menudo, a una rama con una solicitud de extracción abierta o en borrador. Existe cierto deseo de acercar esto al desarrollo local para obtener una retroalimentación más rápida sobre los errores de pelusa, pero esto aún no está respaldado.

Linters compatibles
Los desarrolladores de GitHub pueden llamar a la acción de GitHub para lustrar su base de código con la siguiente lista de linters:

Idioma	Linter
Ansible	pelusa ansible
Administrador de recursos de Azure (ARM)	brazo-ttk
Plantillas de AWS CloudFormation	cfn-pelusa
C#	formato dotnet
CSS	stylelint
Clojure	clj-kondo
CoffeeScript	coffeelint
Dardo	dartanalyzer
Dockerfile	dockerfilelint / hadolint
EDITORCONFIG	editorconfig-checker
ENV	dotenv-linter
Pepinillo	pelusa de pepinillo
Golang	golangci-pelusa
Groovy	npm-groovy-pelusa
HTML	HTMLHint
Java	estilo de verificación
JavaScript	eslint / js estándar
JSON	jsonlint
Kubeval	kubeval
Kotlin	ktlint
Látex	ChkTex
Lua	luacheck
Reducción	markdownlint
OpenAPI	espectral
Perl	perlcrítico
PHP	PHP integrado en la desfibradora / PHP CodeSniffer / PHPStan / Salmo
Potencia Shell	PSScriptAnalyzer
Búferes de protocolo	protolint
Python3	pylint / flake8 / negro / isort
R	lintr
Raku	Raku
Rubí	RuboCop
Cáscara	Shellcheck / [comprobación de bits ejecutables] / shfmt
Serpiente	snakefmt / snakemake --lint
SQL	sql-pelusa
Tekton	tekton-pelusa
Terraform	tflint / terrascan
Terragrunt	terragrunt
Mecanografiado	eslint / js estándar
XML	LibXML
YAML	YamlLint
Cómo utilizar
Tutorial más detallado disponible

Para usar esta acción de GitHub , deberá completar lo siguiente:

Crea un nuevo archivo en tu repositorio llamado .github/workflows/linter.yml
Copie el flujo de trabajo de ejemplo de abajo en ese nuevo archivo, no se requiere configuración adicional
Confirme ese archivo en una nueva rama
Abra una solicitud de extracción y observe cómo funciona la acción
Disfrute de su base de código más estable y limpia
Consulte la Wiki para conocer las opciones de personalización
NOTA: Si pasa la variable de entornoGITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }} en su flujo de trabajo, GitHub Super-Linter marcará el estado de cada ejecución de linter individual en la sección Verificaciones de una solicitud de extracción. Sin esto, solo verá el estado general de la ejecución completa. No es necesario establecer el secreto de GitHub, ya que GitHub lo establece automáticamente, solo debe pasarse a la acción.

Ejemplo de conexión de flujo de trabajo de acción de GitHub
En su repositorio debe tener una .github/workflowscarpeta con GitHub Action similar a la siguiente:

.github/workflows/linter.yml
Este archivo debe tener el siguiente código:

---
 # ######################### 
# ################### ####### 
# # Acciones de Linter GitHub ## 
# ######################### 
# ######## ################## 
nombre : Lint Code Base

# 
# Documentación: 
# https://help.github.com/en/articles/workflow-syntax-for-github-actions 
#

# ############################ 
# Iniciar el trabajo en todas las pulsaciones # 
# ############ ################ 
en :
   empuje :
     ramas-ignoran : [amo] 
    # Retire la línea anterior a ejecutar cuando se empuja al maestro 
  pull_request :
     ramas : [maestro]

# ############## 
# configurar el trabajo # 
# ############## 
trabajos :
   construcción :
     # Nombre del trabajo 
    Nombre : Pelusa Código Básico 
    # Set el agente para ejecutar en 
    ejecuciones : ubuntu-latest

    # ################# 
    # Cargar todos los pasos # 
    # ################ 
    pasos :
       # ###### ################### 
      # Comprobar el código base # 
      # ####################### # 
      - nombre : Código de pago 
        utiliza : acciones / pago @ v2 
        con :
           # Se necesita un historial completo de git para obtener una lista adecuada de archivos modificados dentro de la profundidad de 
          búsqueda de `super-linter` : 0

      # ############################### 
      # Ejecutar Linter contra código base # 
      # ########## #################### 
      - nombre : Lint Code Base 
        usa : github / super-linter @ v3 
        env :
           VALIDATE_ALL_CODEBASE : false 
          DEFAULT_BRANCH : master 
          GITHUB_TOKEN : $ {{secretos .GITHUB_TOKEN}}
Agregue la insignia Super-Linter en su repositorio README
Puede mostrar el estado de Super-Linter con una insignia en su repositorio README

GitHub Super-Linter

Formato:

[! [ GitHub Super-Linter ] (https://github.com/ <PROPIETARIO> / <REPOSITORIO> /workflows/Lint%20Code%20Base/badge.svg)](https://github.com/marketplace/actions / superlinter)
Ejemplo:

[! [ GitHub Super-Linter ] (https://github.com/nvuillam/npm-groovy-lint/workflows/Lint%20Code%20Base/badge.svg)] (https://github.com/marketplace/actions / superlinter)
Nota: SI no usó Lint Code Basecomo nombre de acción de GitHub, lea la documentación de Insignias de acciones de GitHub

Variables de entorno
El superlinter permite pasar las siguientes ENVvariables para poder activar distintas funcionalidades.

Nota: Todas las VALIDATE_[LANGUAGE]variables se comportan de una forma muy específica:

Si no se pasa ninguno de ellos, todos serán verdaderos por defecto.
Si alguna de las variables se establece en verdadero, por defecto dejamos cualquier variable sin establecer en falso (solo validamos esos idiomas).
Si alguna de las variables se establece en falso, de forma predeterminada, dejamos cualquier variable sin establecer en verdadero (solo excluimos esos idiomas).
Si hay VALIDATE_[LANGUAGE]variables establecidas tanto en verdadero como en falso. Fracasará.
Esto significa que si ejecuta el linter "fuera de la caja", se marcarán todos los idiomas. Pero si desea seleccionar o excluir linters específicos, le damos control total para elegir qué linters se ejecutan y no ejecutaremos nada inesperado.

ENV VAR	Valor por defecto	Notas
ACTIONS_RUNNER_DEBUG	false	Marcar para habilitar información adicional sobre el linter, versiones y salida adicional.
ANSIBLE_DIRECTORY	/ansible	Marcar para establecer el directorio raíz para la (s) ubicación (es) del archivo Ansible, relativo a DEFAULT_WORKSPACE. Configure en .para usar el nivel superior de DEFAULT_WORKSPACE.
CSS_FILE_NAME	.stylelintrc.json	Nombre de archivo para la configuración de Stylelint (ej .: .stylelintrc.yml, .stylelintrc.yaml)
DEFAULT_BRANCH	master	El nombre de la rama predeterminada del repositorio.
DEFAULT_WORKSPACE	/tmp/lint	La ubicación que contiene los archivos para lint si está ejecutando localmente.
DISABLE_ERRORS	false	Marcar para tener el linter completo con el código de salida 0 incluso si se detectaron errores.
DOCKERFILE_HADOLINT_FILE_NAME	.hadolint.yml	Nombre de archivo para configuración hadolint (ex: .hadolintlintrc.yaml)
EDITORCONFIG_FILE_NAME	.ecrc	Nombre de archivo para la configuración del editorconfig-checker
ERROR_ON_MISSING_EXEC_BIT	false	Si se establece en false, el bash-execlinter informará una advertencia si un script de shell no es ejecutable. Si se establece en true, el bash-execlinter informará un error en su lugar.
FILTER_REGEX_EXCLUDE	none	Definición de la expresión regular que los archivos serán excluidos de la pelusa (por ejemplo: .*src/test.*)
FILTER_REGEX_INCLUDE	all	Definición de la expresión regular que los archivos serán procesados por borras de (ex: .*src/.*)
JAVASCRIPT_ES_CONFIG_FILE	.eslintrc.yml	Nombre de archivo para configuración eslint (ex: .eslintrc.yml, .eslintrc.json)
JAVASCRIPT_DEFAULT_STYLE	standard	Marcar para establecer el estilo predeterminado de javascript. Opciones disponibles: estándar / más bonita
LINTER_RULES_PATH	.github/linters	Directorio para todas las reglas de configuración de linter.
ARCHIVO DE REGISTRO	super-linter.log	El nombre de archivo para generar registros. Toda la salida se envía al archivo de registro independientemente de LOG_LEVEL.
NIVEL DE REGISTRO	VERBOSE	Cuánta salida generará el script en la consola. Uno de ERROR, WARN, NOTICE, VERBOSE, DEBUGo TRACE.
MULTI_STATUS	true	Se crea una API de estado para cada idioma enlazado para facilitar el análisis visual.
MARKDOWN_CONFIG_FILE	.markdown-lint.yml	Nombre de archivo para configuración Markdownlint (ex: .markdown-lint.yml, .markdownlint.json, .markdownlint.yaml)
FORMATO DE SALIDA	none	El formato del informe que se generará, además del estándar. El formato de salida de tap utiliza actualmente v13 de la especificación. Formatos admitidos: toque
OUTPUT_FOLDER	super-linter.report	La ubicación donde se generarán los informes de salida. La carpeta de salida no debe existir previamente.
OUTPUT_DETAILS	simpler	Qué nivel de detalles se informará. Formatos admitidos: más simple o detallado.
PYTHON_BLACK_CONFIG_FILE	.python-black	Nombre de archivo para la configuración negra (ej .: .isort.cfg, pyproject.toml)
PYTHON_FLAKE8_CONFIG_FILE	.flake8	Nombre de archivo para la configuración de flake8 (ej .: .flake8, tox.ini)
PYTHON_ISORT_CONFIG_FILE	.isort.cfg	Nombre de archivo para la configuración de isort (ej .: .isort.cfg, pyproject.toml)
PYTHON_PYLINT_CONFIG_FILE	.python-lint	Nombre de archivo para configuración pylint (ex: .python-lint, .pylintrc)
RUBY_CONFIG_FILE	.ruby-lint.yml	Nombre de archivo para configuración rubocop (ex: .ruby-lint.yml, .rubocop.yml)
SUPPRESS_POSSUM	false	Si se establece en true, ocultará la zarigüeya ASCII en la parte superior de la salida del registro. El valor predeterminado esfalse
SNAKEMAKE_SNAKEFMT_CONFIG_FILE	.snakefmt.toml	Nombre de archivo para la configuración de Snakemake (ej .: pyproject.toml, .snakefmt.toml)
TYPESCRIPT_ES_CONFIG_FILE	.eslintrc.yml	Nombre de archivo para configuración eslint (ex: .eslintrc.yml, .eslintrc.json)
VALIDATE_ALL_CODEBASE	true	Analizará todo el repositorio y encontrará todos los archivos para validar en todos los tipos. NOTA: Cuando se establece en false, solo los archivos nuevos o editados se analizarán para su validación.
VALIDATE_ANSIBLE	true	Marcar para habilitar o deshabilitar el proceso de borrado del idioma Ansible.
VALIDATE_ARM	true	Marcar para habilitar o deshabilitar el proceso de borrado del lenguaje ARM.
VALIDATE_BASH	true	Marcar para habilitar o deshabilitar el proceso de bloqueo del lenguaje Bash.
VALIDATE_BASH_EXEC	true	Marcar para habilitar o deshabilitar el proceso de vinculación del lenguaje Bash para validar si el archivo está almacenado como ejecutable.
VALIDATE_CLOJURE	true	Marcar para habilitar o deshabilitar el proceso de linting del lenguaje Clojure.
VALIDATE_CLOUDFORMATION	true	Marcar para habilitar o deshabilitar el proceso de vinculación del lenguaje AWS Cloud Formation.
VALIDATE_COFFEE	true	Marcar para habilitar o deshabilitar el proceso de borrado del lenguaje Coffeescript.
VALIDATE_CSHARP	true	Marcar para habilitar o deshabilitar el proceso de bloqueo del lenguaje C #.
VALIDATE_CSS	true	Marcar para habilitar o deshabilitar el proceso de bloqueo del lenguaje CSS.
VALIDATE_DART	true	Marcar para habilitar o deshabilitar el proceso de bloqueo del idioma Dart.
VALIDATE_DOCKERFILE	true	Marcar para habilitar o deshabilitar el proceso de vinculación del idioma de Docker.
VALIDATE_DOCKERFILE_HADOLINT	true	Marcar para habilitar o deshabilitar el proceso de vinculación del idioma de Docker.
VALIDATE_EDITORCONFIG	true	Marcar para habilitar o deshabilitar el proceso de linting con el editorconfig.
VALIDATE_ENV	true	Marcar para habilitar o deshabilitar el proceso de borrado del idioma ENV.
VALIDATE_GHERKIN	true	Marcar para habilitar o deshabilitar el proceso de borrado del idioma Gherkin.
VALIDATE_GO	true	Marcar para habilitar o deshabilitar el proceso de vinculación del idioma Golang.
VALIDATE_GROOVY	true	Marcar para habilitar o deshabilitar el proceso de borrado del idioma.
VALIDATE_HTML	true	Marcar para habilitar o deshabilitar el proceso de bloqueo del lenguaje HTML.
VALIDATE_JAVA	true	Marcar para habilitar o deshabilitar el proceso de borrado del idioma.
VALIDATE_JAVASCRIPT_ES	true	Marcar para habilitar o deshabilitar el proceso de linting del lenguaje Javascript. (Utilizando: eslint)
VALIDATE_JAVASCRIPT_STANDARD	true	Marcar para habilitar o deshabilitar el proceso de linting del lenguaje Javascript. (Utilizando: estándar)
VALIDATE_JSON	true	Marcar para habilitar o deshabilitar el proceso de vinculación del lenguaje JSON.
VALIDATE_JSX	true	Marcar para habilitar o deshabilitar el proceso de linting para archivos jsx (utilizando: eslint)
VALIDATE_KOTLIN	true	Marcar para habilitar o deshabilitar el proceso de vinculación del idioma Kotlin.
VALIDATE_KUBERNETES_KUBEVAL	true	Marcar para habilitar o deshabilitar el proceso de vinculación de descriptores de Kubernetes con Kubeval
VALIDATE_LATEX	true	Marcar para habilitar o deshabilitar el proceso de linting del lenguaje LaTeX.
VALIDATE_LUA	true	Marcar para habilitar o deshabilitar el proceso de borrado del idioma.
VALIDATE_MARKDOWN	true	Marcar para habilitar o deshabilitar el proceso de bloqueo del lenguaje Markdown.
VALIDATE_OPENAPI	true	Marcar para habilitar o deshabilitar el proceso de bloqueo del lenguaje OpenAPI.
VALIDATE_PERL	true	Marcar para habilitar o deshabilitar el proceso de bloqueo del lenguaje Perl.
VALIDATE_PHP	true	Marcar para habilitar o deshabilitar el proceso de vinculación del lenguaje PHP. (Utilizando: linter incorporado de PHP) (conservar para compatibilidad con versiones anteriores)
VALIDATE_PHP_BUILTIN	true	Marcar para habilitar o deshabilitar el proceso de vinculación del lenguaje PHP. (Utilizando: linter incorporado de PHP)
VALIDATE_PHP_PHPCS	true	Marcar para habilitar o deshabilitar el proceso de vinculación del lenguaje PHP. (Utilizando: PHP CodeSniffer)
VALIDATE_PHP_PHPSTAN	true	Marcar para habilitar o deshabilitar el proceso de vinculación del lenguaje PHP. (Utilizando: PHPStan)
VALIDATE_PHP_PSALM	true	Marcar para habilitar o deshabilitar el proceso de vinculación del lenguaje PHP. (Utilizando: Salmo)
VALIDATE_PROTOBUF	true	Marcar para habilitar o deshabilitar el proceso de linting del lenguaje Protobuf.
VALIDATE_PYTHON	true	Marcar para habilitar o deshabilitar el proceso de vinculación del lenguaje Python. (Utilizando: pylint) (conservar para compatibilidad con versiones anteriores)
VALIDATE_PYTHON_BLACK	true	Marcar para habilitar o deshabilitar el proceso de vinculación del lenguaje Python. (Utilizando: negro)
VALIDATE_PYTHON_FLAKE8	true	Marcar para habilitar o deshabilitar el proceso de vinculación del lenguaje Python. (Utilizando: flake8)
VALIDATE_PYTHON_ISORT	true	Marcar para habilitar o deshabilitar el proceso de vinculación del lenguaje Python. (Utilizando: isort)
VALIDATE_PYTHON_PYLINT	true	Marcar para habilitar o deshabilitar el proceso de vinculación del lenguaje Python. (Utilizando: pylint)
VALIDATE_POWERSHELL	true	Marcar para habilitar o deshabilitar el proceso de linting del idioma Powershell.
VALIDATE_R	true	Marcar para habilitar o deshabilitar el proceso de bloqueo del lenguaje R.
VALIDATE_RAKU	true	Marcar para habilitar o deshabilitar el proceso de ligadura del idioma Raku.
VALIDATE_RUBY	true	Marcar para habilitar o deshabilitar el proceso de bloqueo del lenguaje Ruby.
VALIDATE_SHELL_SHFMT	true	Marcar para habilitar o deshabilitar el proceso de vinculación de los scripts de Shell. (Utilizando: shfmt)
VALIDATE_SNAKEMAKE_LINT	true	Marcar para habilitar o deshabilitar el proceso de borrado de Snakefiles. (Utilizando: snakemake --lint)
VALIDATE_SNAKEMAKE_SNAKEFMT	true	Marcar para habilitar o deshabilitar el proceso de borrado de Snakefiles. (Utilizando: snakefmt)
VALIDATE_STATES	true	Marcar para habilitar o deshabilitar el proceso de vinculación para AWS States Language.
VALIDATE_SQL	true	Marcar para habilitar o deshabilitar el proceso de linting del lenguaje SQL.
VALIDATE_TEKTON	true	Marcar para habilitar o deshabilitar el proceso de borrado del lenguaje Tekton.
VALIDATE_TERRAFORM	true	Marcar para habilitar o deshabilitar el proceso de linting del lenguaje Terraform.
VALIDATE_TERRAFORM_TERRASCAN	true	Marcar para habilitar o deshabilitar el proceso de bloqueo del lenguaje Terraform por problemas relacionados con la seguridad.
VALIDATE_TERRAGRUNT	true	Marcar para habilitar o deshabilitar el proceso de borrado de archivos Terragrunt.
VALIDATE_TSX	true	Marcar para habilitar o deshabilitar el proceso de linting para archivos tsx (utilizando: eslint)
VALIDATE_TYPESCRIPT_ES	true	Marcar para habilitar o deshabilitar el proceso de borrado del lenguaje Typecript. (Utilizando: eslint)
VALIDATE_TYPESCRIPT_STANDARD	true	Marcar para habilitar o deshabilitar el proceso de borrado del lenguaje Typecript. (Utilizando: estándar)
VALIDATE_XML	true	Marcar para habilitar o deshabilitar el proceso de vinculación del lenguaje XML.
VALIDATE_YAML	true	Marcar para habilitar o deshabilitar el proceso de vinculación del lenguaje YAML.
YAML_CONFIG_FILE	.yaml-lint.yml	Nombre de archivo para la configuración de Yamllint (ej .: .yaml-lint.yml, .yamllint.yml)
Archivos de reglas de plantilla
Puede usar GitHub Super-Linter con o sin sus propios conjuntos de reglas personales. Esto permite una mayor flexibilidad para cada base de código individual. Todas las reglas de la plantilla intentan seguir los estándares que creemos deberían habilitarse en el nivel básico.

Copie cualquiera o todos los archivos de reglas de plantilla desde TEMPLATES/su repositorio en la ubicación:.github/linters/ de su repositorio
Si su repositorio no tiene archivos de reglas, volverán a los valores predeterminados en la TEMPLATEcarpeta de este repositorio.
Usando sus propios archivos de reglas
Si su repositorio contiene sus propios archivos de reglas que viven fuera de un .github/linters/directorio, tendrá que decirle a Super-Linter dónde se encuentran sus archivos de reglas en su repositorio y cuáles son sus nombres de archivo. Para obtener más información, consulte Uso de sus propios archivos de reglas .

Deshabilitar reglas
Si necesita deshabilitar ciertas reglas y funciones , puede ver Deshabilitar reglas

Filtrar archivos con pelusa
Si necesita pelusa solo una carpeta o excluir algunos archivos de la pelusa, puede usar parámetros de entorno opcionales FILTER_REGEX_INCLUDE yFILTER_REGEX_EXCLUDE

Ejemplos:

Carpeta src de solo pelusa: FILTER_REGEX_INCLUDE: .*src/.*
No deje pelusa en los archivos dentro de la carpeta de prueba: FILTER_REGEX_EXCLUDE: .*test/.*
No deje pelusa los archivos javascript dentro de la carpeta de prueba: FILTER_REGEX_EXCLUDE: .*test/.*.js
Docker Hub
El contenedor de Docker que se crea a partir de este repositorio se encuentra en github / super-linter

Ejecute Super-Linter fuera de las acciones de GitHub
Local (resolución de problemas / depuración / mejoras)
Si encuentra que necesita ejecutar super-linter localmente, puede seguir la documentación en Ejecución de super-linter localmente

Consulte la nota en Cómo funciona para comprender más acerca de Super-Linter linting localmente versus vía integración continua.

Azur
Mira este artículo

GitLab
Vea este fragmento y esta exploración guiada: Extensión de CD de GitLab CI para Super-Linter

Código de Visual Studio
Puede verificar este repositorio usando Container Remote Development y depurar el linter usando la Test Lintertarea. Ejemplo

También admitiremos los espacios de código de GitHub una vez que esté disponible

Limitaciones
A continuación, se muestra una lista de las limitaciones conocidas de GitHub Super-Linter :

Debido a que está completamente empaquetado en tiempo de ejecución, no podrá actualizar las dependencias ni cambiar las versiones de los linters y binarios adjuntos.
Los detalles adicionales de package.jsonno son leídos por elGitHub Super-Linter
La descarga de bases de código adicionales como dependencias de repositorios privados fallará debido a la falta de permisos
Cómo contribuir
Si desea ayudar a contribuir a esta acción de GitHub , consulte CONTRIBUYENDO

Licencia
Licencia MIT
