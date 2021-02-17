class Example {
    static void main(String[] args) {
        File file = new File("E:/Example.txt")
        println "The file ${file.absolutePath} has ${file.length()} bytes"
    }
}
