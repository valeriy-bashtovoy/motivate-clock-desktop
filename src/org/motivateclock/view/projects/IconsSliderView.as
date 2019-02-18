package org.motivateclock.view.projects
{

    import flash.display.MovieClip;
    import flash.display.SimpleButton;
    import flash.display.Sprite;
    import flash.events.Event;
    import flash.events.MouseEvent;

    import org.motivateclock.Model;
    import org.motivateclock.events.ModelEvent;
    import org.motivateclock.interfaces.IProcess;
    import org.motivateclock.model.Project;
    import org.motivateclock.resource.ResourceLib;
    import org.motivateclock.utils.RegularUtils;

    /**
     * @author: Valeriy Bashtovoy
     *
     */
    public class IconsSliderView extends MovieClip
    {
        private var _leftButton:SimpleButton;
        private var _rightButton:SimpleButton;
        private var _maskLayer:MovieClip;
        private var _container:Sprite;
        private var _moveX:int;
        private var _project:Project;
        private var _gfx:MovieClip;
        private var _model:Model;

        public function IconsSliderView(model:Model)
        {
            _model = model;

            _gfx = RegularUtils.getInstanceFromLib(ResourceLib.GFX_PROJECT_ICON_LINE_VIEW) as MovieClip;
            addChild(_gfx);

            _leftButton = _gfx["leftButton"];
            _rightButton = _gfx["rightButton"];
            _maskLayer = _gfx["maskLayer"];

            _maskLayer.width += 20;
            _rightButton.x += 20;

            addEventListener(MouseEvent.CLICK, buttonClickHandler);
            addEventListener(MouseEvent.MOUSE_WHEEL, wheelHandler);
        }

        public function get numIcon():int
        {
            return _container.numChildren;
        }

        public function setProject(value:Project):void
        {
            _project = value;

            create();
        }

        private function addIcon(process:IProcess, withReposition:Boolean = true):void
        {
            var icon:IconItemRenderer = new IconItemRenderer(process);
            icon.enableEditMode();

            _container.addChild(icon);

            if (withReposition)
            {
                reposit();
            }
        }

        private function removeIcon(process:IProcess):void
        {
            var icon:IconItemRenderer;

            for (var i:int = 0; i < _container.numChildren; i++)
            {
                icon = _container.getChildAt(i) as IconItemRenderer;

                if (icon.process.path == process.path)
                {
                    _container.removeChild(icon);
                    icon.dispose();
                }
            }

            reposit();
        }

        private function wheelHandler(event:MouseEvent):void
        {
            if (event.delta > 0)
            {
                move(-1);
            }
            else
            {
                move(1);
            }
        }

        private function buttonClickHandler(event:MouseEvent):void
        {
            switch (event.target)
            {
                case _leftButton:
                    move(1);
                    break;
                case _rightButton:
                    move(-1);
                    break;
            }
        }

        private function move(vector:int):void
        {
            _moveX += _maskLayer.width * vector + (3 * vector);

            var end:int = (_maskLayer.x + _maskLayer.width) - _container.width + 6;

            if (_moveX < end)
            {
                _moveX = end;
            }

            if (_moveX > _maskLayer.x || _container.width < _maskLayer.width)
            {
                _moveX = _maskLayer.x;
            }

            _leftButton.enabled = (_moveX == end);
            _rightButton.enabled = (_moveX == _maskLayer.x);

            _container.x = _moveX;

            checkContains();
        }

        private function checkContains():void
        {
            var icon:IconItemRenderer;

            for (var i:int = 0; i < _container.numChildren; i++)
            {
                icon = _container.getChildAt(i) as IconItemRenderer;

                if (_maskLayer.hitTestObject(icon))
                {
                    icon.showIcon();
                }
            }
        }

        private function mouseClickHandler(event:MouseEvent):void
        {
            var icon:IconItemRenderer = event.target as IconItemRenderer;

            _project.processModel.remove(icon.process);
        }

        private function reposit():void
        {
            var startX:int = 0;
            var hitNum:int = 0;

            for (var i:int = 0; i < _container.numChildren; i++)
            {
                var icon:IconItemRenderer = _container.getChildAt(i) as IconItemRenderer;
                icon.x = startX;
                startX += 16 + 5;

                if (_maskLayer.hitTestObject(icon))
                {
                    hitNum++;
                }
            }

            if (hitNum < 2)
            {
                move(1);
            }

            checkContains();

            dispatchEvent(new Event(Event.CHANGE));
        }

        private function setDefault():void
        {
            _container.x = _maskLayer.x;
            _moveX = _container.x;
        }

        private function create():void
        {
            if (!_container)
            {
                _container = new Sprite();
                _container.mask = _maskLayer;
                _container.y -= 8;
                addChild(_container);

                _maskLayer.x += 1;

                _container.addEventListener(MouseEvent.CLICK, mouseClickHandler);
            }

            if (_project)
            {
                _project.processModel.addEventListener(ModelEvent.PROCESS_ADD, process_Handler);
                _project.processModel.addEventListener(ModelEvent.PROCESS_REMOVE, process_Handler);
            }

            RegularUtils.removeAllChildren(_container);

            reposit();

            setDefault();

            checkContains();

            move(1);
        }

        private function process_Handler(event:ModelEvent):void
        {
            switch (event.type)
            {
                case ModelEvent.PROCESS_ADD:
                    addIcon(event.process);
                    break;
                case ModelEvent.PROCESS_REMOVE:
                    removeIcon(event.process);
                    break;
            }
        }

        public function dispose():void
        {
            if (!_project)
            {
                return;
            }

            _project.processModel.removeEventListener(ModelEvent.PROCESS_ADD, process_Handler);
            _project.processModel.removeEventListener(ModelEvent.PROCESS_REMOVE, process_Handler);
        }
    }
}
