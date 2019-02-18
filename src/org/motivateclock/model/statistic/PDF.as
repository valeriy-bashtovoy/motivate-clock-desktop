package org.motivateclock.model.statistic
{

    import cmodule.as3_jpeg_wrapper.CLibInit;

    import flash.display.Bitmap;
    import flash.display.BitmapData;
    import flash.display.Sprite;
    import flash.events.Event;
    import flash.events.IOErrorEvent;
    import flash.filesystem.File;
    import flash.filesystem.FileMode;
    import flash.filesystem.FileStream;
    import flash.text.TextFormat;
    import flash.utils.ByteArray;

    import org.motivateclock.Model;
    import org.motivateclock.enum.TextKeyEnum;
    import org.motivateclock.events.McEvent;
    import org.motivateclock.model.Project;
    import org.motivateclock.model.settings.Settings;
    import org.motivateclock.utils.RegularUtils;
    import org.motivateclock.utils.TimeUtils;
    import org.purepdf.Font;
    import org.purepdf.colors.RGBColor;
    import org.purepdf.elements.Anchor;
    import org.purepdf.elements.Annotation;
    import org.purepdf.elements.Chunk;
    import org.purepdf.elements.Element;
    import org.purepdf.elements.Paragraph;
    import org.purepdf.elements.Phrase;
    import org.purepdf.elements.RectangleElement;
    import org.purepdf.elements.images.ImageElement;
    import org.purepdf.events.PageEvent;
    import org.purepdf.pdf.PageSize;
    import org.purepdf.pdf.PdfContentByte;
    import org.purepdf.pdf.PdfDocument;
    import org.purepdf.pdf.PdfPTable;
    import org.purepdf.pdf.PdfViewPreferences;
    import org.purepdf.pdf.PdfWriter;
    import org.purepdf.pdf.fonts.BaseFont;
    import org.purepdf.pdf.fonts.FontsResourceFactory;

    /**
     * @author: Valeriy Bashtovoy
     *
     */
    public class PDF extends Sprite
    {
        public static const UNKNOWN_PROCESS:String = "Unknown";

        [Embed(source="/../resources/fonts/tahoma.ttf", mimeType="application/octet-stream")]
        private var tahoma:Class;

        [Embed(source="/../resources/images/vk.jpg")]
        private var vkLogo:Class;

        [Embed(source="/../resources/images/fb.jpg")]
        private var fbLogo:Class;

        [Embed(source="/../resources/images/tw.jpg")]
        private var twLogo:Class;

        [Embed(source="/../resources/images/logo.jpg")]
        private var logo:Class;

        public static const TAHOMA_NORMAL:String = "tahoma.ttf";
        public static var jpegLoader:CLibInit = new CLibInit();
        public static var jpegLib:Object = jpegLoader.init();

        private var _buffer:ByteArray;
        private var _writer:PdfWriter;
        private var _document:PdfDocument;
        private var _filename:String = "statistics.pdf";
        private var _font:Font;
        private var _titleFont:Font;
        private var _baseFont:BaseFont;
        private var _footer:PdfPTable;
        private var _workTimeColor:RGBColor;
        private var _restTimeColor:RGBColor;
        private var _blackfont:Font;
        private var _project:Project;
        private var _statisticResults:Array;
        private var _anchorFont:Font;
        private var _greyFont:Font;
        private var _monthCollection:Array = [];
        private var _pdfFile:File;
        private var _dateCollection:Array = [];
        private var _isCanceled:Boolean = false;

        private var _model:Model;
        private var _settings:Settings;

        public function PDF(model:Model)
        {
            _model = model;

            _settings = _model.settingModel.settings;

            FontsResourceFactory.getInstance().registerFont(PDF.TAHOMA_NORMAL, new tahoma());

            _baseFont = BaseFont.createFont(PDF.TAHOMA_NORMAL, BaseFont.IDENTITY_H, BaseFont.EMBEDDED);
            _titleFont = new Font(Font.UNDEFINED, 14, Font.NORMAL, new RGBColor(46, 101, 118), _baseFont);
            _font = new Font(Font.UNDEFINED, 12, Font.UNDEFINED, null, _baseFont);
            _blackfont = new Font(Font.UNDEFINED, 12, Font.UNDEFINED, RGBColor.BLACK, _baseFont);
            _anchorFont = new Font(Font.UNDEFINED, 12, Font.UNDERLINE, null, _baseFont);
            _greyFont = new Font(Font.UNDEFINED, 14, Font.UNDEFINED, new RGBColor(191, 191, 191), _baseFont);

            _buffer = new ByteArray();

            _workTimeColor = new RGBColor(141, 142, 21);
            _restTimeColor = new RGBColor(145, 3, 3);

            _writer = PdfWriter.create(_buffer, PageSize.A4);
            _document = _writer.pdfDocument;
            _document.addAuthor("Motivate Clock");
            _document.addCreator("https://motivateclock.org");
            _document.setViewerPreferences(PdfViewPreferences.PrintScalingNone);

            _document.addEventListener(PageEvent.PAGE_END, onEndPage);
        }

        public function create(projectId:String, statisticResults:Array):void
        {
            _statisticResults = statisticResults;
            _project = _model.projectModel.getProjectById(projectId);
            _filename = _project.name;

            _document.open();

            addFooter();

            addHeader();

            addProjectStatus();

            var day:StatDay;
            var oldDay:StatDay;
            var dayCollection:Array = [];
            var dateObject:Object;

            for each (var item:Object in statisticResults)
            {
                if (!day || day.date != item.usedDate)
                {
                    day = new StatDay(_project);
                    day.date = item.usedDate;
                    _monthCollection.push(day);
                }
                day.addApplication(item);

                if (!oldDay || day.year != oldDay.year || day.month != oldDay.month)
                {
                    oldDay = day;
                    dayCollection = [];
                    dateObject = {};
                    dateObject.day = day;
                    dateObject.days = dayCollection;
                    _dateCollection.push(dateObject);
                }
                dayCollection.push(day);
            }

            addMoths();
            addDays();

            _document.close();

            checkSum(_monthCollection);

            save();
        }

        private function checkSum(days:Array):void
        {
            var projectTime:Number = _project.restTime + _project.workTime;
            var daysTime:Number = 0;

            for each (var day:StatDay in days)
            {
                daysTime += day.restTime + day.workTime;
            }

            trace('\n-----------------------------------');
            trace(this, 'Project total time:', projectTime);
            trace(this, 'Total time by days:', daysTime);
            if (projectTime != daysTime)
                trace(this, 'Error! Project total time and total time by days aren\'t equal.');
            trace('-----------------------------------\n');
        }

        public function destroy():void
        {
            _pdfFile = null;

            _buffer.clear();
            _document.removeEventListener(PageEvent.PAGE_END, onEndPage);

            _buffer = null;
            _writer = null;
            _document = null;
            _font = null;
            _titleFont = null;
            _baseFont = null;
            _footer = null;
        }

        public function cancel():void
        {
            _isCanceled = true;
        }

        private function addDays():void
        {
            for each (var day:StatDay in _monthCollection)
            {
                addDay(day.date, day.workTime, day.restTime);

                day.workApp.sortOn("time", Array.NUMERIC);
                day.workApp.reverse();
                day.restApp.sortOn("time", Array.NUMERIC);
                day.restApp.reverse();

                for each (var workApp:Object in day.workApp)
                {
                    if (workApp.appName == "")
                        workApp.appName = PDF.UNKNOWN_PROCESS;

                    addApp(workApp, _workTimeColor);
                }

                if (!_model.settingModel.settings.exportRestStat)
                {
                    continue;
                }

                for each (var restApp:Object in day.restApp)
                {
                    if (restApp.appName == "")
                        restApp.appName = PDF.UNKNOWN_PROCESS;

                    addApp(restApp, _restTimeColor);
                }
            }
        }

        private function addMoths():void
        {
            _titleFont.size = 14;
            _titleFont.color = new RGBColor(128, 128, 128);

            _font.size = 14;
            _font.color = new RGBColor(72, 68, 68);

            var dateObject:Object;
            var paragraph:Paragraph;
            var monthIndex:int;
            var year:int;
            var day:StatDay;

            for each (dateObject in _dateCollection)
            {
                day = dateObject.day as StatDay;
                monthIndex = day.month - 1;
                year = day.year;

                paragraph = new Paragraph(_model.languageModel.getText(TextKeyEnum.PDF_YEAR) + ": ", _titleFont);
                paragraph.setLeading(1, 2);
                paragraph.add(new Phrase(String(year), _font));

                paragraph.add(new Phrase("  " + _model.languageModel.getText(TextKeyEnum.PDF_MONTH) + ": ", _titleFont));
                paragraph.add(new Phrase(TimeUtils.getMonthNameByIndex(monthIndex), _font));
                _document.add(paragraph);

                paragraph = new Paragraph(_model.languageModel.getText(TextKeyEnum.PDF_DAY) + ": ", _titleFont);
                addAnchors(paragraph, TimeUtils.getNumDayInMonth(year, monthIndex), dateObject.days);
                _document.add(paragraph);
            }
        }

        private function addAnchors(paragraph:Paragraph, daysNum:int, dayCollection:Array):void
        {
            _anchorFont.size = 14;
            _anchorFont.color = new RGBColor(38, 106, 124);

            var anchor:Anchor;
            var phrase:Phrase = new Phrase("|", _greyFont);
            var dayIndex:int;

            for (var i:int = 0; i < daysNum; i++)
            {
                dayIndex = i + 1;

                anchor = new Anchor(String(dayIndex), _greyFont);

                for each (var mocloDay:StatDay in dayCollection)
                {
                    if (mocloDay.day == dayIndex)
                    {
                        anchor = new Anchor(String(dayIndex), _anchorFont);
                        anchor.reference = "#" + mocloDay.date;//join("-");
                        break;
                    }
                }

                paragraph.add(anchor);

                if (i != (daysNum - 1))
                {
                    paragraph.add(phrase);
                }
            }
        }

        private function addProjectStatus():void
        {
            //			var allTimeParagraph:Paragraph = new Paragraph(null);
            //			allTimeParagraph.setLeading(1, 1.7);

            _titleFont.size = 14;
            _titleFont.color = new RGBColor(128, 128, 128);

            var totalSec:int = 0;
            var time:Object = 0;
            var dayName:String = "";

            var workTimeParagraph:Paragraph = new Paragraph(null);
            workTimeParagraph.setLeading(1, 1.7);

            workTimeParagraph.add(new Phrase("     " + _model.languageModel.getText(TextKeyEnum.PDF_INTO_ACCOUNT) + " ", _titleFont));

            _font.size = 14;
            _font.color = new RGBColor(161, 162, 0);
            workTimeParagraph.add(new Phrase(_model.languageModel.getText(TextKeyEnum.PDF_WORKING) + " ", _font));

            workTimeParagraph.add(new Phrase(_model.languageModel.getText(TextKeyEnum.PDF_TIME) + ": ", _titleFont));

            time = TimeUtils.convertSeconds(_project.workTime, _settings.workingHours);
            dayName = " " + TimeUtils.getDeclensionNumberName(time.day, _model.languageModel.getText(TextKeyEnum.DAY).split(",")) + " ";
            workTimeParagraph.add(new Phrase(time.day + dayName + time.hour + ":" + time.min + ":" + time.sec, _font));

            _document.add(workTimeParagraph);

            totalSec = _project.workTime + _project.restTime;

            var workPercent:Number = _project.workTime / totalSec;
            var resetPercent:Number = _project.restTime / totalSec;
            var idlePercent:Number = 0; //1 - (workPercent + resetPercent);

            showTextAt(Math.round(workPercent * 100) + "%", Element.ALIGN_RIGHT, 14, _font.color, _document.pageSize.width - _document.marginRight, _document.getVerticalPosition(false));

            addRectangle(_document.marginLeft, _document.getVerticalPosition(false) + 1, 10, 10, _font.color);

            var restTimeParagraph:Paragraph = new Paragraph(null, _font);
            restTimeParagraph.setLeading(1, 1.7);

            restTimeParagraph.add(new Phrase("     " + _model.languageModel.getText(TextKeyEnum.PDF_INTO_ACCOUNT) + " ", _titleFont));

            _font.size = 14;
            _font.color = new RGBColor(145, 3, 3);
            restTimeParagraph.add(new Phrase(_model.languageModel.getText(TextKeyEnum.PDF_RESTING) + " ", _font));

            restTimeParagraph.add(new Phrase(_model.languageModel.getText(TextKeyEnum.PDF_TIME) + ": ", _titleFont));

            time = TimeUtils.convertSeconds(_project.restTime, _settings.workingHours);
            dayName = " " + TimeUtils.getDeclensionNumberName(time.day, _model.languageModel.getText(TextKeyEnum.DAY).split(",")) + " ";
            restTimeParagraph.add(new Phrase(time.day + dayName + time.hour + ":" + time.min + ":" + time.sec, _font));

            _document.add(restTimeParagraph);

            showTextAt(Math.round(resetPercent * 100) + "%", Element.ALIGN_RIGHT, 14, _font.color, _document.pageSize.width - _document.marginRight, _document.getVerticalPosition(false));

            addRectangle(_document.marginLeft, _document.getVerticalPosition(false) + 1, 10, 10, _font.color);

            _document.add(new Paragraph(" ", _font));

            addStatusLine(_document.pageSize.width - _document.marginLeft - _document.marginRight, 8, workPercent, resetPercent, idlePercent);
        }

        private function showTextAt(text:String, align:int, size:int, fontColor:RGBColor, x:int, y:int):void
        {
            var cb:PdfContentByte = _document.getDirectContent();
            cb.beginText();
            cb.setFontAndSize(_baseFont, size);
            cb.setColorFill(fontColor);
            cb.showTextAligned(align, text, x, y, 0);
            cb.endText();
        }

        private function addStatusLine(totalWidth:Number, height:Number, workPercent:Number, restPercent:Number, idlePercent:Number):void
        {
            var width:Number = totalWidth * workPercent;
            var x:Number = _document.marginLeft;
            var color:RGBColor = new RGBColor(161, 162, 0);

            addRectangle(x, _document.getVerticalPosition(false) + 1, width, height, color);

            x += width;
            width = totalWidth * restPercent;
            color = new RGBColor(145, 3, 3);

            addRectangle(x, _document.getVerticalPosition(false) + 1, width, height, color);

            x += width;
            width = totalWidth * idlePercent;
            color = new RGBColor(229, 229, 229);

            addRectangle(x, _document.getVerticalPosition(false) + 1, width, height, color);
        }

        private function addRectangle(x:int, y:int, width:int, height:int, color:RGBColor):void
        {
            var cb:PdfContentByte = _document.getDirectContent();
            var r:RectangleElement = new RectangleElement(x, y, x + width, y + height);
            r.backgroundColor = color;
            cb.rectangle(r);
        }

        private function addHeader():void
        {
            addRectangle(0, _document.getVerticalPosition(false) - 34, _document.pageSize.width, 100, new RGBColor(59, 139, 160));

            var fieldWidth:int;
            var x:int = 210;
            var y:int = _document.getVerticalPosition(false) + 15;
            showTextAt(RegularUtils.truncateStringByLength(_project.name, 46), Element.ALIGN_LEFT, 16, RGBColor.WHITE, x, y);

            y -= 20;
            var created:String = _model.languageModel.getText(TextKeyEnum.PDF_CREATED) + ":";
            showTextAt(created, Element.ALIGN_LEFT, 13, new RGBColor(174, 210, 219), x, y);
            fieldWidth = RegularUtils.getPdfFieldWidthByString(created, new TextFormat("tahoma", 13)) + 4;

            var date:Date = _project.creationDate;
            var month:String = TimeUtils.setDoubleFormat(date.getMonth() + 1);
            var day:String = TimeUtils.setDoubleFormat(date.getDate());
            showTextAt(date.getFullYear() + "-" + month + "-" + day, Element.ALIGN_LEFT, 13, RGBColor.WHITE, x + fieldWidth, y);

            y -= 20;
            var active:String = _model.languageModel.getText(TextKeyEnum.SETTINGS_WORKING_HOURS) + ":";
            showTextAt(active, Element.ALIGN_LEFT, 13, new RGBColor(174, 210, 219), x, y);

            fieldWidth = RegularUtils.getPdfFieldWidthByString(active, new TextFormat("tahoma", 13)) + 4;

            const hourName:String = " " + TimeUtils.getDeclensionNumberName(_settings.workingHours, _model.languageModel.getText(TextKeyEnum.HOUR).split(",")) + " ";

            showTextAt(_settings.workingHours + hourName, Element.ALIGN_LEFT, 13, RGBColor.WHITE, x + fieldWidth, y);// + int(time.sec) + secName

            var p:Paragraph = new Paragraph(" ", _font);
            p.setLeading(3, 3);
            _document.add(p);

            var image:ImageElement = getImage(Bitmap(new logo()).bitmapData, _document.left() - 6, _document.getVerticalPosition(false) + 5, 170, "https://motivateclock.org/");
            _document.getDirectContent().addImage(image);
        }

        private function getImage(bitmapData:BitmapData, x:int, y:int, scale:Number, url:String = ""):ImageElement
        {
            var bytesSource:ByteArray = bitmapData.getPixels(bitmapData.rect);
            var bytes:ByteArray = PDF.jpegLib.write_jpeg_file(bytesSource, bitmapData.width, bitmapData.height, 3, 2, 100);
            var image:ImageElement = ImageElement.getInstance(bytes);
            image.scaleToFit(scale, scale);
            image.setAbsolutePosition(x, y);

            if (url)
            {
                image.annotation = Annotation.createUrl(url);
            }

            return image;
        }

        private function addDay(date:String, workTime:Number, restTime:Number):void
        {
            trace(this, 'day', date, 'workTime', workTime, 'restTime', restTime);

            _font.size = 14;
            _font.color = new RGBColor(38, 106, 124);

            //			_document.add(new Paragraph(" ", _titleFont));

            var paragraph:Paragraph = new Paragraph(null);
            paragraph.setLeading(1, 3.5);

            var dataAnchor:Anchor = new Anchor(date, _font);
            dataAnchor.name = date;
            paragraph.add(dataAnchor);

            _blackfont.size = 14;

            _document.add(paragraph);

            var width:int = 244;//261;
            var x:int = _document.marginLeft + 80;
            var y:Number = _document.getVerticalPosition(false) + 2;

            var daySec:int = 24 * 60 * 60;
            var workPct:Number = workTime / daySec;
            var restPct:Number = restTime / daySec;

            var greenWidth:Number = width * workPct;
            addRectangle(x, y, greenWidth, 7, new RGBColor(161, 162, 0));

            x += greenWidth;

            var redWidth:Number = width * restPct;
            addRectangle(x, y, redWidth, 7, new RGBColor(145, 3, 3));

            x += redWidth;

            var grayWidth:Number = width * (1 - (workPct + restPct));
            addRectangle(x, y, grayWidth, 7, new RGBColor(229, 229, 229));

            x += grayWidth;

            var work:Object = TimeUtils.convertSeconds(workTime, _settings.workingHours);
            var workTimeString:String = TimeUtils.setDoubleFormat(work.hour) + ":" + TimeUtils.setDoubleFormat(work.min) + ":" + TimeUtils.setDoubleFormat(work.sec);

            var rest:Object = TimeUtils.convertSeconds(restTime, _settings.workingHours);
            var restTimeString:String = TimeUtils.setDoubleFormat(rest.hour) + ":" + TimeUtils.setDoubleFormat(rest.min) + ":" + TimeUtils.setDoubleFormat(rest.sec);

            y -= 0.5;

            var fieldWidth:int = 0;

            var workLabel:String = _model.languageModel.getText(TextKeyEnum.WORK) + ": ";
            showTextAt(workLabel, Element.ALIGN_LEFT, 12, RGBColor.BLACK, x + 10, y);
            fieldWidth = RegularUtils.getPdfFieldWidthByString(workLabel, new TextFormat("tahoma", 12)) + 4;

            showTextAt(workTimeString, Element.ALIGN_LEFT, 12, new RGBColor(161, 162, 0), x + fieldWidth, y);

            var restLabel:String = _model.languageModel.getText(TextKeyEnum.REST) + ": ";
            showTextAt(restLabel, Element.ALIGN_LEFT, 12, RGBColor.BLACK, x + 110, y);
            fieldWidth = RegularUtils.getPdfFieldWidthByString(restLabel, new TextFormat("tahoma", 12)) + 4;

            showTextAt(restTimeString, Element.ALIGN_LEFT, 12, new RGBColor(145, 3, 3), x + 100 + fieldWidth, y);
        }

        private function addApp(app:Object, color:RGBColor):void
        {
            var time:Object = TimeUtils.convertSeconds(app.time, _settings.workingHours);

            _font.color = color;
            _font.size = 12;
            _blackfont.size = 12;

            var paragraph:Paragraph = new Paragraph(null);
            paragraph.setLeading(1, 1.5);
            var chunk:Chunk = new Chunk(time.hour + ":" + time.min + ":" + time.sec + "   ", _font);
            paragraph.add(chunk);
            paragraph.add(new Phrase(app.appName, _blackfont));

            _document.add(paragraph);

            var y:int = _document.getVerticalPosition(false) - 5;

            var cb:PdfContentByte = _document.getDirectContent();
            cb.setLineWidth(0.5);
            cb.setRGBStrokeColor(191, 191, 191);
            cb.moveTo(_document.marginLeft, y);
            cb.lineTo(_document.pageSize.width - _document.marginRight, y);
            cb.stroke();
        }

        private function addFooter():void
        {
            _footer = new PdfPTable(3);
            _footer.totalWidth = 300;
            _footer.defaultCell.horizontalAlignment = Element.ALIGN_CENTER;
            _footer.defaultCell.border = RectangleElement.NO_BORDER;

            var image:ImageElement = getImage(Bitmap(new fbLogo()).bitmapData, 0, 0, 0, "https://www.facebook.com/motivateclock");
            _footer.addImageCell(image);

            image = getImage(Bitmap(new twLogo()).bitmapData, 0, 0, 0, "https://twitter.com/#!/motivateclock");
            _footer.addImageCell(image);

            image = getImage(Bitmap(new vkLogo()).bitmapData, 0, 0, 0, "https://vkontakte.org/club22295080");
            _footer.addImageCell(image);
        }

        private function save():void
        {
            if (_isCanceled)
            {
                browseEventHandler();
                return;
            }

            var date:Date = new Date();
            var name:String = "_" + date.getFullYear() + "_" + (date.getMonth() + 1) + "_" + date.getDate();
            name += "_" + date.getHours() + "_" + date.getMinutes() + "_" + date.getSeconds() + ".pdf";

            _filename = _filename.replace(/\s/ig, "_");
            _filename = _filename.replace(/[<>?*:"\|\\]/ig, "");
            _filename += name;

            _pdfFile = File.desktopDirectory.resolvePath(_filename);

            try
            {
                _pdfFile.browseForSave(_model.languageModel.getText(TextKeyEnum.PDF_SAVE_AS));
                _pdfFile.addEventListener(Event.SELECT, selectPathHandler);
                _pdfFile.addEventListener(IOErrorEvent.IO_ERROR, browseEventHandler);
                _pdfFile.addEventListener(Event.CANCEL, browseEventHandler);
            }
            catch (error:Error)
            {
            }
        }

        private function browseEventHandler(event:Event = null):void
        {
            destroy();
            dispatchEvent(new McEvent(McEvent.PDF_SAVED));
        }

        private function selectPathHandler(event:Event):void
        {
            var stream:FileStream = new FileStream();
            stream.addEventListener(Event.COMPLETE, saveCompleteHandler);
            stream.addEventListener(Event.CLOSE, saveCompleteHandler);
            stream.addEventListener(IOErrorEvent.IO_ERROR, saveErrorHandler);
            stream.openAsync(_pdfFile, FileMode.WRITE);
            stream.writeBytes(_buffer);
            stream.close();
        }

        private function saveErrorHandler(event:IOErrorEvent):void
        {
            browseEventHandler();
        }

        private function saveCompleteHandler(event:Event):void
        {
            _pdfFile.openWithDefaultApplication();
            browseEventHandler();
        }

        private function onEndPage(event:PageEvent):void
        {
            var cb:PdfContentByte = _writer.getDirectContent();
            _footer.writeSelectedRows2(0, -1, (_document.right() - _document.left() - 300) / 2 + _document.marginLeft, _document.bottom() - 10, cb);
        }
    }
}
