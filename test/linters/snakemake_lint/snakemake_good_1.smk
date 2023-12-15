rule all:
    input:
        file1="result.txt",


rule simulation:
    output:
        file1="result.txt",
    log:
        "logs/simulation.log",
    conda:
        "envs/simulation.yml"
    shell:
        """
        touch {output}
        """
