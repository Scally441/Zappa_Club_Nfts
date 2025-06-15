#
# Imports
#
import argparse
import shutil
from pathlib import Path


#
# Constants
#

OUTPUT_DIR_NAME: str = "metadata"
METADATA_TEMPLATE: str = """{{
    "name": "Zappa Club Ticket - {event_city} {event_date}",
    "description": "Ticket for the Zappa Club event in {event_city} on {event_date}",
    "external_url": "https://zappaclub.io",
    "image": "ipfs://{image_ipfs_id}",
    "attributes": [
        {{
          "trait_type": "Event date",
          "value": "{event_date}"
        }},
        {{
          "trait_type": "Event time",
          "value": "{event_time}"
        }},
        {{
          "trait_type": "Event city",
          "value": "{event_city}"
        }},
        {{
          "trait_type": "Event location",
          "value": "{event_location}"
        }}
    ]
}}
"""
CONTRACT_METADATA_TEMPLATE: str = """{{
    "name": "Zappa Club Tickets",
    "description": "Tickets for Zappa Club events",
    "external_url": "https://zappaclub.io",
    "image": "ipfs://{image_ipfs_id}"
}}
"""


#
# Functions
#

def CreateOutputFolder() -> None:
    print("Creating output folder...")

    try:
        shutil.rmtree(OUTPUT_DIR_NAME)
    except FileNotFoundError:
        pass
    Path(OUTPUT_DIR_NAME).mkdir(parents=True, exist_ok=True)


def ValidateArguments(args: argparse.Namespace) -> None:
    if args.token_id < 0:
        raise ValueError("Invalid token ID")


def ParseArguments() -> argparse.Namespace:
    parser = argparse.ArgumentParser()
    parser.add_argument(
        "--contract-ipfs",
        type=str,
        required=False,
        help="Contract IPFS CID"
    )
    parser.add_argument(
        "--token-ipfs",
        type=str,
        required=True,
        help="Token IPFS CID"
    )
    parser.add_argument(
        "--token-id",
        type=int,
        required=True,
        help="Token ID"
    )
    parser.add_argument(
        "--date",
        type=str,
        required=True,
        help="Event date"
    )
    parser.add_argument(
        "--time",
        type=str,
        required=True,
        help="Event time"
    )
    parser.add_argument(
        "--city",
        type=str,
        required=True,
        help="Event city"
    )
    parser.add_argument(
        "--location",
        type=str,
        required=True,
        help="Event location"
    )

    args = parser.parse_args()
    ValidateArguments(args)

    return args


def CreateContractMetadataFile(ipfs: str) -> None:
    print("Creating metadata for token contract...")
    with open(Path(OUTPUT_DIR_NAME) / "contract", "w") as fout:
        fout.write(
            CONTRACT_METADATA_TEMPLATE.format(
                image_ipfs_id=ipfs
            )
        )


def CreateTokenMetadataFiles(ipfs: str,
                             token_id: int,
                             date: str,
                             time: str,
                             city: str,
                             location: str) -> None:
    print(f"Creating metadata for token #{token_id}...")
    with open(Path(OUTPUT_DIR_NAME) / str(token_id), "w") as fout:
        fout.write(
            METADATA_TEMPLATE.format(
                image_ipfs_id=ipfs,
                event_date=date,
                event_time=time,
                event_city=city,
                event_location=location
            )
        )


#
# Main
#

def main() -> None:
    CreateOutputFolder()
    args = ParseArguments()

    CreateTokenMetadataFiles(args.token_ipfs, args.token_id, args.date, args.time, args.city, args.location)
    CreateContractMetadataFile(args.contract_ipfs or f"{args.token_ipfs}/contract.png")


#
# Execute main
#

if __name__ == "__main__":
    main()