from brownie import FundMe, config, network, MockV3Aggregator
from scripts.helpful_scripts import getAccount, deploy_mocks, LOCAL_BLOCKCHAIN_ENVIRONMENTS

def deploy_fund_me():
    account = getAccount()

    # if we are not on a development network, then pull the current active network's price feed from our .yaml file (.show_active())
    if network.show_active() not in LOCAL_BLOCKCHAIN_ENVIRONMENTS:
        price_feed_address = config["networks"][network.show_active()][
            "eth_usd_price_feed"
        ]
    else:
        deploy_mocks()
        price_feed_address = MockV3Aggregator[-1].address

    fund_me = FundMe.deploy(
        price_feed_address,
        {"from": account},
        publish_source=config["networks"][network.show_active()].get("verify")
    )
    print(f"Contract deployed to {fund_me.address}")
    return fund_me


def main():
    deploy_fund_me()