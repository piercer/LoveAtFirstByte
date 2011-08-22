package
{

    import flash.events.Event;

    public class ChatEvent extends Event
    {

        public static const MESSAGE:String = "message";
        private var _message:String;

        public function ChatEvent( message:String )
        {
            super( MESSAGE );
            _message = message;
        }

        public function get message():String
        {
            return _message;
        }
    }

}
