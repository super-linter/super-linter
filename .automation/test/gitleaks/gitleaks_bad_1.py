# Based on https://github.com/zricethezav/gitleaks/blob/6f5ad9dc0b385c872f652324188ce91da7157c7c/test_data/test_repos/test_dir_1/server.test2.py
# Do not hard code credentials
client = boto3.client(
    's3',
    # Hard coded strings as credentials, not recommended.
    aws_access_key_id='AKIAIO5FODNN7EXAMPLE',
    aws_secret_access_key='ABCDEF+c2L7yXeGvUyrPgYsDnWRRC1AYEXAMPLE'
)

# gh_pat = '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'
