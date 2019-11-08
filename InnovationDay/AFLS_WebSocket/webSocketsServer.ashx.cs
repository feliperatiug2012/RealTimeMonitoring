using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using Microsoft.Web.WebSockets;

namespace AFLS_WebSocket
{
    public class webSocketsServer : IHttpHandler
    {
        public bool IsReusable
        {
            get
            {
                return true;
            }
        }
        public void ProcessRequest(HttpContext context)
        {
            if (context.IsWebSocketRequest)
            {
                context.AcceptWebSocketRequest(new MicrosoftWebSockets());
            }
            else
            {
                context.Response.ContentType = "text/plain";
                context.Response.Write("just simple and test text response");
                context.Response.End();
            }
        }
    }
}