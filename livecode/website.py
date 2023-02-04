from flask import Flask, render_template
from gql.schema import schema
import urllib.parse
from flask_minify import Minify

app = Flask(__name__)

Minify(app=app, html=True, js=True, cssless=True)


def _get_common_data():
    return schema.execute_sync(
        """
    {
        years
        partySeries {
            name
            gqlId
            stub
        }
        allEventType {
            label
            stub
        }
    }"""
    )


def nav_context(
    year=None,
    serie=None,
    performer=None,
    event_type=None,
    event=None,
    about=None,
    upcomings=None,
):
    return {
        'year': year,
        'serie': serie,
        'event': event,
        'performer': performer,
        'eventType': event_type,
        'about': about,
        'upcomings': upcomings,
    }


@app.route("/index.html")
def index():
    return by_year("2023")


@app.route("/about.html")
def about():
    common = _get_common_data()
    return render_template(
        "about.html", nav_context=nav_context(about=True), **common.data
    )


@app.route("/upcomings.html")
def upcomings():
    common = _get_common_data()
    result = schema.execute_sync(
        """ 
    {
    upcomings {
        title
        started
        type {
            label
            stub
        }
        flyer
        website
        staffs {
        job
        handle {
            displayName
        }
        }
        softwareUsed{
        name
        }
    }
    }
    """
    )
    return render_template(
        "upcomings.html",
        nav_context=nav_context(upcomings=True),
        **common.data,
        **result.data,
    )


@app.route("/performer/<stub>.html")
def performer_page(stub):
    stub = urllib.parse.quote(stub)
    common = _get_common_data()
    result = schema.execute_sync(
        """
    query perHandle($stub:String!){
        events:eventsByHandle(stub:$stub) {
            handle {
                displayName,
                demozooId
            }
            performerEvents {
                gqlId
                title 
                type {
                  label
                  stub
                }
                started
                date
                vod
                demozooPartyId
                softwareUsed {
                    name
                    url
                    purpose
                    version
                }
                phases {
                    vod
                    title
                    entries {
                        points
                        previewUrl
                        handle{
                             name:displayName
                             demozooId
                             stub
                        }
                        rank 
                        points
                        shadertoyUrl 
                        sourceFile 
                        tic80CartId
                        vod
                    }
                }
                partySerie {
                    name
                    website
                    demozooUrl
                    stub
                }
            }
            staffEvents {
                gqlId
                title 
                type {
                  label
                  stub
                }
                started
                date
                vod
                staffs {
                    handle {
                        displayName
                        stub
                    }
                    job
                }
                demozooPartyId
                softwareUsed {
                    name
                    url
                    purpose
                    version
                }
                phases {
                    vod
                    title
                    staffs {
                        handle {
                            displayName
                            stub
                        }
                        job
                    }
                }
                partySerie {
                    name
                    website
                    demozooUrl
                    stub
                }
            }
        }
    }""",
        variable_values={"stub": stub},
    )
    return render_template(
        "by_performer.html",
        nav_context=nav_context(performer={"selected": stub}),
        **common.data,
        **result.data,
    )


@app.route("/performers.html")
def all_performer():
    common = _get_common_data()
    result = schema.execute_sync(
        """{     
        allHandles {
            letter
            handles {
              displayName
              stub
            }
        }
    }"""
    )
    return render_template(
        "all_performer.html",
        nav_context=nav_context(performer={"selected": None}),
        **common.data,
        **result.data,
    )


@app.route("/year/<year>.html")
def by_year(year):
    common = _get_common_data()
    result = schema.execute_sync(
        """
    query byYear($year: ID!){
        events:	year(id:$year) {
     			title 
                type {
                  label
                  stub
                }
                started
                date
                vod
                demozooPartyId
                gqlId
                softwareUsed {
                    name
                    url
                    purpose
                    version
                }
                staffs {
                    handle {
                        displayName
                        stub
                    }
                    job
                }
                phases {
                    vod
                    staffs {
                        handle {
                            displayName
                            stub
                        }
                        job
                    }
                    title
                    keyword
                    entries {
                        points
                        previewUrl
                        handle{
                             name:displayName
                             stub
                        }
                        rank 
                        points 
                        shadertoyUrl 
                        sourceFile 
                        tic80CartId
                        vod
                    }

                }
                partySerie {
                    name
                    website
                    demozooUrl
                    stub
                }
  		}
    }""",
        variable_values={"year": year},
    )
    return render_template(
        "by_year.html",
        nav_context=nav_context(year=year),
        **common.data,
        **result.data,
    )


@app.route("/serie/<serie_stub>.html")
def by_serie(serie_stub):
    serie_stub = urllib.parse.quote(serie_stub)
    common = _get_common_data()
    result = schema.execute_sync(
        """
     query byPartySerie($partySerie: String!){
        serie:partySerieByStub(stub:$partySerie) {
            name
            url
            website
            demozooUrl

            events {
                gqlId
                title 
                type {
                  label
                  stub
                }
                softwareUsed {
                    name
                    url
                    purpose
                    version
                }
                staffs {
                    handle {
                        displayName
                        stub
                    }
                    job
                }
                started
                date
                vod
                demozooPartyId
                phases {
                    vod
                    staffs {
                        handle {
                            displayName
                            stub
                        }
                        job
                    }
                    title
                    entries {
                        points
                        previewUrl
                        handle{
                             name:displayName
                             stub
                        }
                        rank 
                        points 
                        shadertoyUrl 
                        sourceFile 
                        tic80CartId
                        vod
                    }

                }
                partySerie {
                    name
                    website
                    demozooUrl
                    stub
                }
            }
        }
    }""",
        variable_values={"partySerie": serie_stub},
    )
    return render_template(
        "by_serie.html",
        nav_context=nav_context(serie=serie_stub),
        **common.data,
        **result.data,
    )


@app.route("/event/<event_stub>.html")
def by_event(event_stub):
    common = _get_common_data()
    result = schema.execute_sync(
        """
     query perHandle($eventId:ID!) {
        event:eventById(gqlId:$eventId){
          gqlId
                title 
                type {
                  label
                  stub
                }
                softwareUsed {
                    name
                    url
                    purpose
                    version
                }
                started
                date
                vod
                demozooPartyId
                staffs {
                    handle {
                        displayName
                        stub
                    }
                    job
                }
                phases {
                    vod
                    staffs {
                        handle {
                            displayName
                            stub
                        }
                        job
                    }
                    title
                    entries {
                        points
                        previewUrl
                        handle{
                             name:displayName
                             stub
                        }
                        rank 
                        points 
                        shadertoyUrl 
                        sourceFile 
                        tic80CartId
                        vod
                    }

                }
                partySerie {
                    name
                    website
                    demozooUrl
                    stub
                }
    
  			}
    }""",
        variable_values={"eventId": event_stub},
    )
    return render_template(
        "by_event.html",
        nav_context=nav_context(event=event_stub),
        **common.data,
        **result.data,
    )


@app.route("/type/<type_stub>.html")
def by_type(type_stub):

    type_stub = urllib.parse.quote(type_stub)

    common = _get_common_data()
    result = schema.execute_sync(
        """
     query perType($eventTypeId:ID!) {
        events:eventsByType(typeStub:$eventTypeId){
                gqlId
                title 
                type {
                  label
                  stub
                }
                started
                date
                vod
                demozooPartyId
                softwareUsed {
                    name
                    url
                    purpose
                    version
                }
                staffs {
                    handle {
                        displayName
                        stub
                    }
                    job
                }
                phases {
                    vod
                    staffs {
                        handle {
                            displayName
                            stub
                        }
                        job
                    }
                    title
                    entries {
                        points
                        previewUrl
                        handle{
                             name:displayName
                             stub
                        }
                        rank 
                        points 
                        shadertoyUrl 
                        sourceFile 
                        tic80CartId
                        vod
                    }

                }
                partySerie {
                    name
                    website
                    demozooUrl
                    stub
                }
    
  			}
    }""",
        variable_values={"eventTypeId": type_stub},
    )
    return render_template(
        "by_type.html",
        nav_context=nav_context(event_type=type_stub),
        **common.data,
        **result.data,
    )
