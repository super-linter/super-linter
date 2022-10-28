// Copyright 2021 GitHub

#include <fstream>
#include <iostream>
using std::string;

int main() {
  // Create and open a text file
  ofstream MyFile("filename.txt");

  // Write to the file
  MyFile << "Files can be tricky, but it is fun enough!";

  // Close the file
  MyFile.close();
}

#ifndef TEST_CPP_CPP_GOOD_01_CPP_
#define TEST_CPP_CPP_GOOD_01_CPP_
#endif  // TEST_CPP_CPP_GOOD_01_CPP_
