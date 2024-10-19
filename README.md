## License

This project is licensed under the GNU General Public License Version 2, June 1991. See the [LICENSE](./LICENSE.md) file for details.

Smart Contract Review - in progress

### SC Descriptions

Anu Initiative Smart Contract Executive Summary
 
The Anu Initiative has successfully deployed six critical smart contracts to the Polygon Amoy testnet to facilitate the operations of its blockchain-based project. These deployments are integral to the initiative's mission, which revolves around enabling and streamlining donations and registrations within its ecosystem. Below is a detailed overview of each contract and its purpose.
 
Connect to Amoy and begin deploying today:

- Network Name: Polygon Amoy Testnet
- New RPC URL: https://rpc-amoy.polygon.technology/
- Chain ID: 80002
- Currency Symbol: MATIC
- Block Explorer URL:  https://amoy.polygonscan.com
- Faucet:  https://faucet.polygon.technology 
 
 
Contract: Anu Initiative Member Registry
- Address: https://amoy.polygonscan.com/address/0x0f208ab5118e6d9c8bfe5b561e22c3b235df2365
- Purpose: This contract maintains the registry of Anu Initiative members and represents the primary interaction point for Anu Initiative members. It records member information and ensures that the registration process is secure and verifiable, forming the backbone of the initiative’s community management. Any account may register for membership via the Register transaction, but an official Anu Initiative Verification Account must do a Verify transaction for each registered account to allow the account to interact with the system and make donations. 

Registration verification will verify that a KYC process has been completed for any given registered account. The Register transaction also allows for an optional referral account to be included, giving credit to the member account responsible for referring the new member. 

Only verified accounts may be included as referral accounts by the Register transaction. Each account registered will be minted a soulbound NFT representing the account’s membership. 

Membership information, such as total amount donated and member rank, is dynamically displayed as part of the NFT metadata in wallets and markets. Once registered and verified an account is able to make donations in any token that has been whitelisted in the contract. The Donate transaction accepts the address of a whitelisted token to be used for the donation and an amount of that token to donate. Regardless of which whitelisted token is used to make a donation, all donation amounts are represented in their current USDC value, and all donations are converted to USDC immediately within the Donate transaction. 
 
All donation amounts are therefore received by the Anu Initiative Treasury account in USDC tokens. Each donation made by verified registered accounts will accrue an amount of reward points determined by the amount donated (in USDC). Once donate-to-earn is activated in the contract, each account with accrued reward points will be able to harvest an equivalent amount of ANU tokens, which are minted directly to the account.
 
Contract: Anu Initiative Donation Registry
- Address: https://amoy.polygonscan.com/address/0xf4bfdd9d72085479c0e740c18bfdc8c8a8692f3e
- Purpose: This contract handles each individual donation made by members of the Anu Initiative. It ensures that contributions are securely processed and accurately recorded, supporting transparency and trust within the donation system. For each donation made the contract will mint a Donation Receipt soulbound NFT directly to the donating account representing a permanent and transparent record of all donations. Each Donation Receipt NFT has dynamic metadata displaying the amount donated in USDC on the NFT in wallets and markets. 
 
The Donation Registry contract is automatically operated by the Member Registry contract during the donation process, so no direct user interaction is required. The Donation Receipt NFT collection itself as a whole represents and displays details of all donations made by Anu Initiative members in an open and transparent way. 
 
Contract: Anu Initiative ANU Token
- Address: https://amoy.polygonscan.com/address/0x8f3db42da7bfd4884fb5696d634cdcf841d1549b
- Purpose: The native token of the Anu Initiative, the ANU Token, is central to the ecosystem. It is used for various functions including staking, governance, and rewarding participants within the Anu platform. Once the ANU token is launched with USDC liquidity pairing, and donate-to-earn is activated, reward points can be harvested as ANU tokens by each account in an amount determined by the total amount of donations made by the account in USDC. 
 
Each member account with accrued reward points can do a Harvest transaction, where ANU tokens are minted directly to the associated account, representing a fully decentralized token distribution donate-to-earn model. In later stages, with an Anu Initiative Autonomous Organization deployed, the ANU token will be stakeable for member governance voting power.
 
Contract: USDC Test Token
- Address: https://amoy.polygonscan.com/address/0x02c9a92fac22ee64f616840808c31eed0dda9bcf
- Purpose: This is a test version of the USDC stablecoin, deployed for use in the absence of an official USDC token on the Polygon Amoy testnet. It allows for stable, dollar-pegged transactions within the Anu ecosystem. All token donations are immediately converted to USDC tokens within the donation transaction.
 
Contract: WMATIC Test Token
- Address: https://amoy.polygonscan.com/address/0xf470bfe69a657fb6169df276b7ce398a90ab0cce
- Purpose: A test version of WMATIC, deployed for use by the Anu Initiative ecosystem in the absence of an official Polygon Amoy testnet version of wrapped MATIC, facilitating donations made with the native Polygon MATIC token.
 
Contract Uniswap Test Router
- Address: https://amoy.polygonscan.com/address/0x09f6e761627702f1ca4b8703913d6ec4381e9864
- Purpose: The Uniswap Test Router simulates the swap functionality of a Uniswap router, in absence of an officially deployed Uniswap (or Quickswap) testnet version on Polygon Amoy. It mocks some basic token router functionalities for on-chain token swapping from whitelist accepted donation tokens to USDC test tokens in the Anu Initiative donation process.
 
 
Remarks about the NFT:
With this run we mainly test the ability to add an image link to SVG and overlay relevant contract data as text on that image in the SVG. The contract builds the SVG dynamically and returns it with the function tokenURL(), which Opensea reads and displays. 
 
Looking at Opensea now, link below, the dynamic text overlay is working and shows the current amount donated by the account, on the NFT display, as well as rank and a display name. 
 
The background image link in the SVG is not being processed by Opensea though for some reason. I think it has to do with this being the testnet Opensea and reducing the resources it uses compared to live Opensea. We know it's working too, because you can click on 'View Original Media' icon in the top right corner of the image, and it displays the dNFT perfectly. 
 
Here is a link: 
https://testnets.opensea.io/assets/amoy/0x0f208ab5118e6d9c8bfe5b561e22c3b235df2365/1 
 
* Notice the image shows a broken image background, and then clicking on 'View Original Media' icon in the top right corner of the image, shows the image perfectly with background image and dynamic text overlay.
