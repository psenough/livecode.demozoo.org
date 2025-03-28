const BONZOMATIC = 0;
const TIC80 = 1;
const BAZEMATIC = 2;
const NYANK = 3;

const participants = {}
let i = 0;;
 // Create WebSocket connection.
 const socket = new WebSocket(this.name);
            
 // Connection opened
 socket.addEventListener("open", (event) => {

    postMessage({"msg":"log","data":"Connected"});
 });

 socket.addEventListener("close", (event) => {

    postMessage({"msg":"log","data":"Closed"});
 });

 socket.addEventListener("error", (event) => {

    postMessage({"msg":"log","data":"Error"});
 });
 // Listen for messages
 socket.addEventListener("message", (event) => {
    postMessage({"msg":"log","data":"Receiving Message"});

    message = {
        'id': undefined,
        'ts':Date.now(),
        'type':undefined,
        'data':undefined,
    }
    try {
        let data = event.data;
        if (data.slice(-1)=='\0') {
           data = data.substring(0, data.length - 1)
        }
        json_parsed = JSON.parse(data);

        if(json_parsed['Data'] !== undefined && 
            json_parsed['Data']['Code'] !== undefined && 
            json_parsed['Data']['Code'].startsWith("#version")){ // Bonzomatic 
            message.type =BONZOMATIC
            message.data = json_parsed
            message.id= `${json_parsed['Data']['RoomName']}/${json_parsed['Data']['NickName']}`
   
        } 
        if(json_parsed["s"]==="tic80") {
            message.type =TIC80
            message.data = json_parsed['data']
            message.id= json_parsed['id']
        }
        participants[message.id] = message;
    } catch (e) {
        console.error(event.data);
        console.error(e);
        //return console.error(e); // error in the above string (in this case, yes)!
     
           
     
    }
 
});

 function tick() {
    const dt_now = Date.now();
    let a = Object.values(participants);
    a = a.sort((a,b)=> a.id.toLowerCase() > b.id.toLowerCase())
    a = a.map(msg => {
        msg.dt = dt_now - msg.ts;
        return msg;
    })
    postMessage({"msg":"event","data":a});
    setTimeout("tick()",500); 
 }
 

  
tick(); 