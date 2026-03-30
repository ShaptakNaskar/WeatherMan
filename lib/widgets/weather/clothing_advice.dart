import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:weatherman/models/weather.dart';
import 'package:weatherman/providers/theme_provider.dart';
import 'package:weatherman/utils/trend_analyzer.dart';
import 'package:weatherman/widgets/themed/themed_card.dart';

/// "What should I wear?" smart summary widget
class ClothingAdviceCard extends StatelessWidget {
  final WeatherData weather;

  const ClothingAdviceCard({super.key, required this.weather});

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    final t = themeProvider.current;
    final advice = _generateAdvice(themeProvider.textStyle);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: ThemedCard(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: t.accentColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(t.cardBorderRadius * 0.6),
              ),
              child: Icon(
                advice.icon,
                color: t.accentColor,
                size: 24,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    advice.headline,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          shadows: t.textShadows,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    advice.detail,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: t.textSecondary,
                          shadows: t.textShadows,
                        ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  static String _t(InsightTextStyle s, String cyber, String kawaii, String neutral) =>
      switch (s) {
        InsightTextStyle.cyber => cyber,
        InsightTextStyle.kawaii => kawaii,
        InsightTextStyle.neutral => neutral,
      };

  _Advice _generateAdvice(InsightTextStyle style) {
    final temp = weather.current.temperature;
    final feelsLike = weather.current.apparentTemperature;
    final uv = weather.current.uvIndex;
    final wind = weather.current.windSpeed;
    final rain = weather.current.rain;
    final humidity = weather.current.relativeHumidity;
    final code = weather.current.weatherCode;

    // Check upcoming rain from hourly
    final now = DateTime.now();
    final next6h = weather.hourly.where(
      (h) => h.time.isAfter(now) && h.time.isBefore(now.add(const Duration(hours: 6))),
    );
    final rainComingSoon = next6h.any((h) => h.precipitationProbability > 50);

    // Check temperature drop
    final laterTemps = next6h.map((h) => h.temperature).toList();
    final willCoolDown = laterTemps.isNotEmpty && laterTemps.last < temp - 5;

    // Thunderstorm
    if (code >= 95) {
      return _Advice(
        icon: Icons.thunderstorm_rounded,
        headline: _t(style,
          'STORM ACTIVE — shelter immediately',
          'Oh no, thunderstorms!',
          'Stay inside if you can',
        ),
        detail: _t(style,
          'EM hazard confirmed. Deploy rain shell if egress required. Avoid open terrain.',
          'Thunderstorms right now! If you have to go out, bring rain gear and stay away from open areas.',
          'Thunderstorms active. If going out, bring rain gear and avoid open areas.',
        ),
      );
    }

    // Heavy rain
    if (rain > 2 || (code >= 63 && code <= 67)) {
      return _Advice(
        icon: Icons.umbrella_rounded,
        headline: _t(style,
          'PRECIP ALERT — waterproof gear',
          'Grab your umbrella!',
          'Grab your umbrella!',
        ),
        detail: _t(style,
          'Heavy rain active. Full waterproof jacket and sealed boots recommended.',
          'It\'s really pouring right now! Waterproof jacket and boots are a must.',
          'Heavy rain right now. Waterproof jacket and boots recommended.',
        ),
      );
    }

    // Light rain or rain coming
    if (rain > 0 || rainComingSoon) {
      final detail = rainComingSoon && rain == 0
          ? _t(style,
              'Dry now but precip inbound. Pack rain shell.',
              'Dry for now, but rain is on the way! Better grab an umbrella just in case.',
              'Dry now but rain expected soon. Bring an umbrella just in case.',
            )
          : _t(style,
              'Light precip. Standard rain jacket sufficient.',
              'A little rainy! A light jacket with a hood should keep you dry.',
              'Light rain. A light jacket with a hood should do.',
            );
      return _Advice(
        icon: Icons.umbrella_rounded,
        headline: _t(style,
          'PRECIP DETECTED — rain gear',
          'It\'s umbrella time!',
          'Rain gear weather',
        ),
        detail: detail,
      );
    }

    // Very cold
    if (feelsLike < -10) {
      return _Advice(
        icon: Icons.ac_unit_rounded,
        headline: _t(style,
          'CRYO-HAZARD — full insulation',
          'Brrr! It\'s freezing!',
          'Bundle up — it\'s freezing',
        ),
        detail: _t(style,
          'Sub-zero thermal hazard. Heavy insulation layer, sealed gloves, face shield. Minimize exposure.',
          'Bundle up in your warmest coat, scarf, and gloves! Don\'t stay outside too long!',
          'Heavy coat, gloves, scarf, and warm boots. Limit time outside.',
        ),
      );
    }

    if (feelsLike < 5) {
      final coolNote = willCoolDown
          ? _t(style, ' Thermal drop imminent.', ' Getting colder later!', ' Getting colder later.')
          : '';
      return _Advice(
        icon: Icons.ac_unit_rounded,
        headline: _t(style,
          'THERMAL WARNING — layer up',
          'Warm layers needed!',
          'Warm layers needed',
        ),
        detail: _t(style,
          'Cold ambient. Deploy coat, sweater, and thermal base layer.$coolNote',
          'Coat, sweater, and a warm layer underneath will keep you cozy!$coolNote',
          'Coat, sweater, and a warm layer underneath.$coolNote',
        ),
      );
    }

    // Cool
    if (feelsLike < 15) {
      final windNote = wind > 20
          ? _t(style, ' Wind chill active — add layer.', ' A bit breezy too, so layer up!', ' It\'s breezy, so layer up.')
          : '';
      return _Advice(
        icon: Icons.checkroom_rounded,
        headline: willCoolDown
            ? _t(style,
                'COOLING TREND — pack jacket',
                'Bring a jacket — it\'ll cool down!',
                'Bring a jacket — it\'ll cool down',
              )
            : _t(style,
                'MILD — light jacket recommended',
                'Light jacket weather!',
                'Light jacket weather',
              ),
        detail: _t(style,
          'Light outer layer optimal. Hoodie or jacket suffices.$windNote',
          'A light jacket or hoodie is perfect for today!$windNote',
          'A light jacket or hoodie is perfect.$windNote',
        ),
      );
    }

    // Very hot
    if (feelsLike > 38) {
      return _Advice(
        icon: Icons.wb_sunny_rounded,
        headline: _t(style,
          'THERMAL OVERLOAD — minimal layers',
          'So hot! Stay cool!',
          'Extreme heat — stay cool',
        ),
        detail: _t(style,
          'Extreme thermal load. Loose breathable fabrics only. Sunscreen mandatory. Maintain hydration.',
          'Light, loose clothing is your best friend today! Sunscreen and lots of water!',
          'Light, loose clothing. Sunscreen is a must. Stay hydrated.',
        ),
      );
    }

    // Hot
    if (feelsLike > 30) {
      String cyberDetail = 'Hot ambient. Light breathable fabrics.';
      String kawaiiDetail = 'Light clothing and breathable fabrics will feel best!';
      String neutralDetail = 'Light clothing and breathable fabrics.';
      if (uv > 6) {
        cyberDetail += ' UV elevated — deploy sunscreen and hat.';
        kawaiiDetail += ' UV is high — don\'t forget sunscreen and a hat!';
        neutralDetail += ' UV is high — sunscreen and a hat.';
      }
      if (humidity > 70) {
        cyberDetail += ' Humidity high — moisture-wicking recommended.';
        kawaiiDetail += ' It\'s humid too, so moisture-wicking clothes help!';
        neutralDetail += ' Humid, so moisture-wicking helps.';
      }
      return _Advice(
        icon: Icons.wb_sunny_rounded,
        headline: _t(style,
          'HOT CONDITIONS — dress light',
          'Hot out — dress light!',
          'Hot out — dress light',
        ),
        detail: _t(style, cyberDetail, kawaiiDetail, neutralDetail),
      );
    }

    // Pleasant with UV warning
    if (uv > 6) {
      return _Advice(
        icon: Icons.wb_sunny_outlined,
        headline: _t(style,
          'UV SPIKE — dermal protection',
          'Sunscreen weather!',
          'Sunscreen weather!',
        ),
        detail: _t(style,
          'Pleasant thermal but UV index elevated. Sunglasses and sunscreen required.',
          'Nice temperature but UV is high! Sunglasses and sunscreen are a must.',
          'Nice temperature but UV is high. Sunglasses and sunscreen recommended.',
        ),
      );
    }

    // Windy
    if (wind > 30) {
      final coolNote = willCoolDown
          ? _t(style, ' Thermal drop later.', ' Gets cooler later too!', ' Gets cooler later.')
          : '';
      return _Advice(
        icon: Icons.air_rounded,
        headline: _t(style,
          'WIND ADVISORY — deploy windbreaker',
          'Windy day ahead!',
          'Windy day ahead',
        ),
        detail: _t(style,
          'High wind velocity. Windbreaker recommended.$coolNote',
          'A windbreaker will make a big difference today!$coolNote',
          'A windbreaker will make a big difference.$coolNote',
        ),
      );
    }

    // Pleasant
    return _Advice(
      icon: Icons.sentiment_satisfied_alt_rounded,
      headline: _t(style,
        'OPTIMAL CONDITIONS — all clear',
        'Yay! Perfect weather!',
        'Perfect weather!',
      ),
      detail: _t(style,
        'All systems nominal. No special gear required. Enjoy the optimal conditions.',
        'Comfortable conditions! Wear whatever makes you happy today ~',
        'Comfortable conditions. Wear whatever you feel like — it\'s a great day.',
      ),
    );
  }
}

class _Advice {
  final IconData icon;
  final String headline;
  final String detail;
  const _Advice({required this.icon, required this.headline, required this.detail});
}
