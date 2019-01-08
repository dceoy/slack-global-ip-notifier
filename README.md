slack-global-ip-notifier
========================

Slack notifier of global IP

Usage
-----

1.  Check out the repository.

    ```sh
    $ git clone https://github.com/dceoy/slack-global-ip-notifier.git
    $ cd slack-global-ip-notifier
    ```

2.  Set `slack_env.sh`.

    ```sh
    $ cp example_slack_env.sh slack_env.sh
    $ vi slack_env.sh # => set environment variables for slack notification
    ```

3.  Test notification.

    ```sh
    $ ./notify.sh --force
    ```

4.  Set `crontab`.

    ```sh
    $ echo "0 * * * * $(pwd)/notify.sh --quiet" > crontab
    $ crontab crontab
    ```
