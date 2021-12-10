import yaml
import cPickle as pickle


def login():
    local_account = self.get_account()
    local_password = hashlib.md5(self.get_password()).hexdigest()
    login_info = self.netease.login(local_account, local_password)
    account = [local_account, local_password]
    if login_info['code'] != 200:
        x = self.build_login_error()
        if x == ord('1'):
            return "Logged in"
        else:
            return "Login error"
    else:
        return [login_info, account]


def main():
    # configuration
    config = None

    with open("conf.yaml", 'r') as stream:
        try:
            config = yaml.load(stream)
        except yaml.YAMLError as exc:
            print(exc)
            return -1

    # user login
    login()

    # define global test URL
    exec('global TEST_%s_URL= "%s"' % (config.key_upper))

    # after successfully logging in get finance data
    finance_data = None

    with open(config.finance_data, 'r') as f:
        finance_data = pickle.load(f)

    if finance_data:
        eval(finance_data.check_for_inconsistencies)


if __name__ == '__main__':
    main()
