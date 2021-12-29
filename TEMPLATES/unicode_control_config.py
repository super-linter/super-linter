scan_exclude = [
    # Iconv test data
    r"/iconvdata/testdata/",
    # Test case data
    r"libio/tst-widetext.input$",
    # Test script.  This is to silence the warning:
    # 'utf-8' codec can't decode byte 0xe9 in position 2118: invalid continuation byte
    # since the script tests mixed encoding characters.
    r"localedata/tst-langinfo.sh$",
]
