import argparse
from generate import freezer
from update.update import update_all_data
from workflow.new_bbc import generate_ffmc
from workflow.upcoming import create_upcoming
import re
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

    parser_workflow_upcoming = workflow_subparser.add_parser(
        "upcoming", help="Generate upcoming event"
    )
    parser_workflow_upcoming.add_argument(
            'date', type=str, help="Date for the event (YYYY-MM-DD)"
    )
    parser_workflow_upcoming.add_argument(
            'title', type=str, help="Title of event"
    )
    parser_workflow_upcoming.add_argument(
            'type', type=str, help="Type of event", choices=["Shader Showdown", "Shader Jam", "Shader Royale", "Byte Battle", "Byte Jam"]
    )
    parser_workflow_upcoming.add_argument(
            '--website', type=str, help="Website of event", required=False
    )
    parser_workflow_upcoming.add_argument(
            '--flyer', type=str, help="Flyer of event", required=False
    )
    parser_workflow_upcoming.add_argument(
            '--contact', type=str, help="Contact for event ", required=False
    )
    parser_workflow_upcoming.add_argument(
            '--looking_for_participant', type=bool, help="Contact for event ", required=False, default=False
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
        if args.workflow == "upcoming":
            date_re=re.compile(r"^\d{4}-\d{2}-\d{2}$")
            if not date_re.match(args.date):
                print("Date format is wrong")
                exit(1)
            create_upcoming(
                args.title,
                args.date,
                args.type,
                args.website,
                args.flyer,
                args.contact,
                args.looking_for_participant
            )

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

