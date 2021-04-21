###############################################

# Run GitHub's Super Linter against code base #

###############################################



name: linter



on: push



jobs:

  run-linters:

    name: Linters

    runs-on: ubuntu-latest



    steps:

      - name: Check out Git repository

        uses: actions/checkout@master

        

      - name: GitHub Super-Linter

        uses: github/super-linter@master

        env:

          VALIDATE_ALL_CODEBASE: true

          DEFAULT_BRANCH: master

          GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
