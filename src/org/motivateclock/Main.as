package org.motivateclock
{

    import flash.display.MovieClip;
    import flash.display.StageAlign;
    import flash.display.StageScaleMode;

    /**
     * @author: Valeriy Bashtovoy
     *
     */
    public class Main extends MovieClip
    {
        private var _model:Model;
        private var _controller:Controller;
        private var _view:View;

        public function Main()
        {
            stage.scaleMode = StageScaleMode.NO_SCALE;
            stage.align = StageAlign.TOP_LEFT;
            stage.stageFocusRect = false;

            _model = new Model();
            _view = new View(_model, this.stage);
            _controller = new Controller(_model, this.stage);
        }
    }
}
