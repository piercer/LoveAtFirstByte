package components
{

    import flash.events.EventDispatcher;
    import flash.events.MouseEvent;

    import spark.components.Button;
    import spark.components.TextArea;
    import spark.components.TextInput;
    import spark.components.supportClasses.SkinnableComponent;

    public class ChatComponent extends SkinnableComponent
    {

        [Inject]
        private var messageBus:EventDispatcher;

        [SkinPart(required="true")]
        public var textInput:TextInput;

        [SkinPart(required="true")]
        public var textOutput:TextArea;

        [SkinPart(required="true")]
        public var submitButton:Button;

        public function ChatComponent()
        {
            messageBus.addEventListener( ChatEvent.MESSAGE, onChatMessage );
        }

        private function onChatMessage( event:ChatEvent ):void
        {
            textOutput.text += event.message + "\n";
        }

        override protected function partAdded( partName:String, instance:Object ):void
        {
            super.partAdded( partName, instance );

            switch ( instance )
            {
                case submitButton:
                    submitButton.addEventListener( MouseEvent.CLICK, onSendClicked );
                    break;
            }

//            if ( instance == submitButton )
//            {
//                submitButton.addEventListener( MouseEvent.CLICK, onSendClicked );
//            }

        }

        private function onSendClicked( event:MouseEvent ):void
        {
            messageBus.dispatchEvent( new ChatEvent( textInput.text ) );
        }

    }

}

/*
 Push specific injector scope onto scope stack to enable location of injector
 */
