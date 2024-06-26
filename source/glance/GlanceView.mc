import Toybox.Graphics;
import Toybox.WatchUi;
import Toybox.Time;
import Toybox.Lang;
import Toybox.Math;
import Toybox.Application;

import Milestones;
import Settings;
import Stats;

(:glance)
class GlanceView extends WatchUi.GlanceView {

  var quitDate;
  private var _appName as String?;
  private var _colorSpace as Number?;
  private var _units;

  private const GROUP_SPACING = 4;
  private const UNIT_SPACING = 0;

  // fonts
  private const _font as FontDefinition = Graphics.FONT_GLANCE;
  private const _unitFont as FontDefinition = Graphics.FONT_TINY;
  private const _dataFont as FontDefinition = Graphics.FONT_GLANCE_NUMBER;
  private const _lineHeight as Number = 7;

  function initialize() {
    GlanceView.initialize();
  }

  // Load your resources here
  function onLayout(dc as Dc) as Void {
    _appName = Application.loadResource( Rez.Strings.AppNameGlance );
    _colorSpace = Properties.getValue("colorSpace");
    _units = [
      Application.loadResource( Rez.Strings.ShortYear ),
      Application.loadResource( Rez.Strings.ShortMonth ),
      Application.loadResource( Rez.Strings.ShortDay ),
      Application.loadResource( Rez.Strings.ShortHour ),
      Application.loadResource( Rez.Strings.ShortMinute )
    ];
  }

  // Called when this View is brought to the foreground. Restore
  // the state of this View and prepare it to be shown. This includes
  // loading resources into memory.
  function onShow() as Void {
    quitDate = Settings.getQuitDate() as Time.Moment;
  }

  // Update the view
  function onUpdate(dc as Dc) as Void {
    // Call the parent onUpdate function to redraw the layout
    View.onUpdate(dc);

    var height = dc.getHeight();
    var width = dc.getWidth();

    var minX = 0.0;
    var minY = 0;
    var subtitleY = height * 0.57;
    var progressY = height / 2;

    // Milestone progress
    // =====|-- Draws the foreground, leaves a gap and from there it draws the remaining background
    var progress = Milestones.milestoneProgress(quitDate) as Lang.Float;
    var progressW = width * progress;

    // progress foreground
    dc.setColor(foregroundColor(Graphics.COLOR_DK_GREEN), Graphics.COLOR_TRANSPARENT);
    dc.setPenWidth(_lineHeight);
    dc.drawLine(minX, progressY, progressW, progressY);
    // progress background
    dc.setColor(foregroundColor(Graphics.COLOR_DK_GRAY), Graphics.COLOR_TRANSPARENT);
    var backgroundLineHeight = _colorSpace > 1 ? Math.floor(_lineHeight / 2) : 1;
    dc.setPenWidth(backgroundLineHeight);
    dc.drawLine(progressW + _lineHeight, progressY, width, progressY);

    // Reset
    dc.setPenWidth(1);
    dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);

    // App name
    dc.drawText(
            minX,
            minY,
            _font,
            _appName,
            Graphics.TEXT_JUSTIFY_LEFT);

    drawElapsedTime(dc, minX, subtitleY, width);
  }

  function drawElapsedTime(dc as Dc, startX as Numeric, y as Numeric, maxWidth as Numeric) as Void {
    var today = new Time.Moment(Time.now().value());
    var elapsedSinceQuit = Stats.elapsedTimeSince(quitDate, today);
    var x = startX;
    var unitY = y + Graphics.getFontAscent(_dataFont) - Graphics.getFontAscent(_unitFont); // baseline for unit

    var keys = [:years, :months, :days, :hours, :minutes];

    for (var i = 0; i < elapsedSinceQuit.size(); i += 1) {
      var unit = _units[i]; // TODO: Make sure this access does not crash
      var data = elapsedSinceQuit.get(keys[i]);

      if (data > 0 || x != startX) { // start drawing from the first non-zero value
        var dataWidth = dc.getTextWidthInPixels(data.toString(), _dataFont) + UNIT_SPACING;
        var unitWidth = dc.getTextWidthInPixels(unit, _unitFont) + GROUP_SPACING;
        // Stop drawign if the rest of the text won't fit the maxWidth
        if ((x + dataWidth + unitWidth) >= maxWidth) { return; }

        // Draw data and unit
        dc.drawText(x, y, _dataFont, data.toString(), Graphics.TEXT_JUSTIFY_LEFT);
        x += dataWidth;
        dc.drawText(x, unitY, _unitFont, unit, Graphics.TEXT_JUSTIFY_LEFT);
        x += unitWidth;
      }
    }
  }

  // Called when this View is removed from the screen. Save the
  // state of this View here. This includes freeing resources from
  // memory.
  function onHide() as Void {
  }

  function foregroundColor(color as Number) as Number {
    return _colorSpace > 1 ? color : Graphics.COLOR_WHITE;
  }

}
