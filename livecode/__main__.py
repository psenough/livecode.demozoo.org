import argparse
from generate import freezer
from update.update import update_all_data
from workflow.new_bbc import generate_ffmc

if __name__ == "__main__":
    parser = argparse.ArgumentParser(prog="livecode")
    subparsers = parser.add_subparsers(dest="command")

    parser_generate = subparsers.add_parser("generate", help="Generate Website")
    parser_update = subparsers.add_parser("update", help="Update Database")
    parser_workflow = subparsers.add_parser(
        "workflow", help="Worflow related command"
    )

    workflow_subparser = parser_workflow.add_subparsers(dest="workflow")
    parser_workflow_add_bbc = workflow_subparser.add_parser(
        "FFMC", help="FieldFx Monday Casual automatic pre-fetch data"
    )
    parser_workflow_add_bbc.add_argument(
        'date', type=str, help="Date of Casual Monday"
    )
    parser_workflow_add_bbc.add_argument(
        'nb_byte_battle',
        default=0,
        type=int,
        help="Number of byte battle planed",
    )

    parser_workflow_add_bbc.add_argument(
        'nb_performer_jam',
        default=4,
        type=int,
        help="Number of performer for byte jam",
    )
    args = parser.parse_args()
    if not args.command:
        parser.print_help()
        exit(1)

    if args.command == "workflow":
        if not args.workflow:
            parser_workflow.print_help()
            exit(1)
        if args.workflow == "FFMC":
            generate_ffmc(args.date, args.nb_byte_battle, args.nb_performer_jam)

    if args.command == 'update':
        """
        Update the database :
            Refresh handles
            Refresh media and fetch media from shadertoy and tic80
            Refresh series data
        """
        update_all_data()
    if args.command == 'generate':
        """
        Command to generate the html form current database
        """
        freezer.freeze()
