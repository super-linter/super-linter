rule all:
    input:
        file1='result.txt',

rule simulation:
    output:
        file1="result.txt"
    shell:
        """
        touch {output}
        """
