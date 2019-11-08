using System;
using System.Collections.Generic;
using System.Linq;
using System.Timers;
using System.Web;
using Microsoft.Web.WebSockets;
namespace AFLS_WebSocket
{
    public class MicrosoftWebSockets:WebSocketHandler
    {
        private static WebSocketCollection clients = new WebSocketCollection();
        private string name;
        private static int conteo=0;
        private static string caden;
        public MicrosoftWebSockets()
        {

        }
        public override void OnOpen()
        {
            this.name = this.WebSocketContext.QueryString["chatName"];
            clients.Add(this);
            clients.Broadcast(name + " Has connected");
            SetTimer();
        }
        private static System.Timers.Timer aTimer;
        private static void SetTimer()
        {
            aTimer = new System.Timers.Timer(2000);
            aTimer.Elapsed += OnTimedEvent;
            aTimer.AutoReset = true;
            aTimer.Enabled = true;
        }
        public static string names(string name)
        {
            return name;
        }
        private static void OnTimedEvent(Object source, ElapsedEventArgs e)
        {
            caden = names(decimal.Parse("-74,07870769500731"),decimal.Parse("4,69215279016557"));
            clients.Broadcast("the elapsed event ddd" + e.SignalTime + " " + caden);
        }
        private static string names(decimal longitude,decimal latitude)
        {
            conteo = conteo + 1;
            longitude = longitude + decimal.Parse("0,0000000010");
            latitude = latitude + decimal.Parse("0,0000000010");
            return "{1;" +  longitude.ToString()  + ";" + latitude.ToString() + ";1;" + conteo.ToString() + "}";
        }
        public override void OnMessage(string message)
        {
            clients.Broadcast("from Server " + message);
        }
        public override void OnClose()
        {
            clients.Remove(this);
            clients.Broadcast(string.Format("{0} has gone away " + name));
            aTimer.Stop();
            aTimer.Dispose();
        }

    }
}