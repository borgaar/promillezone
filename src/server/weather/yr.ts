interface YrResponse {
  properties: {
    timeseries: YrEntry[];
    meta: {
      updated_at: string;
    };
  };
}

interface YrEntry {
  time: Date;
  instant: {
    details: YrDetails;
  };
  next_1_hours?: YrPeriod;
  next_6_hours?: YrPeriod;
  next_12_hours?: YrPeriod;
}

interface YrPeriod {
  summary: {
    symbol_code: string;
  };
  details: YrDetails;
}

interface YrDetails {
  air_pressure_at_sea_level?: number;
  air_temperature?: number;
  cloud_area_fraction?: number;
  relative_humidity?: number;
  wind_from_direction?: number;
  wind_speed?: number;
}

interface WeatherHour {
  time: Date;
  temperature: number;
  symbol: string;
  // precipitation: number;
  wind: {
    speed: number;
    direction: number;
  };
}

interface WeatherDay {
  date: Date;
  hours: WeatherHour[];
  average: {
    temperature: number;
    precipitation: number;
    wind: {
      speed: number;
      direction: number;
    };
  };
}

export interface WeatherData {
  days: WeatherDay[];
  updatedAt: Date;
}

export class WeatherProvider {
  static async getForecast(lat: string, lon: string): Promise<WeatherData> {
    const response = await fetch(
      "https://api.met.no/weatherapi/locationforecast/2.0/compact?lat=${lat}&lon=${lon}" +
        new URLSearchParams({
          lat: lat,
          lon: lon,
        }).toString(),
    );

    if (!response.ok) {
      console.error(response);
      throw Error("Failed to fetch weather");
    }

    const yr_data = (await response.json()) as YrResponse;

    const timeseries = yr_data.properties.timeseries;

    const hours = timeseries.map((entry) => {
      let symbol: string;
      if (entry.next_1_hours) {
        symbol = entry.next_1_hours.summary.symbol_code;
      } else if (entry.next_6_hours) {
        symbol = entry.next_6_hours.summary.symbol_code;
      } else if (entry.next_12_hours) {
        symbol = entry.next_12_hours.summary.symbol_code;
      } else {
        symbol = "unknown";
      }

      return {
        // Using ! is safe as all stats are always present in 'instant' object
        time: entry.time,
        temperature: entry.instant.details.air_temperature!,
        symbol: symbol,
        // precipitation logic must be different, so I will do this later
        // precipitation:
        wind: {
          speed: entry.instant.details.wind_speed!,
          direction: entry.instant.details.wind_from_direction!,
        },
      } as WeatherHour;
    });

    const days: WeatherDay[] = [];

    // Group hours by day and present proper data
    for (const hour of hours) {
      if (!days.find((d) => d.date.getDate() != hour.time.getDate())) {
        const day: WeatherDay = {
          date: new Date(
            hour.time.getFullYear(),
            hour.time.getMonth(),
            hour.time.getDate(),
          ),
          average: {
            temperature: 0,
            precipitation: 0,
            wind: {
              speed: 0,
              direction: 0,
            },
          },
          hours: [hour],
        };
        days.push(day);
      } else {
        const day = days.find((d) => d.date.getDate() != hour.time.getDate())!;
        day.hours.push(hour);
      }
    }

    for (const day of days) {
      day.average.temperature =
        day.hours.reduce((acc, h) => acc + h.temperature, 0) / day.hours.length;
      day.average.wind.speed =
        day.hours.reduce((acc, h) => acc + h.wind.speed, 0) / day.hours.length;
      // Averaging wind direction like this doesn't reeeaaally make sense, but whatever
      day.average.wind.direction =
        day.hours.reduce((acc, h) => acc + h.wind.direction, 0) /
        day.hours.length;
    }

    return {
      days: days,
      updatedAt: new Date(yr_data.properties.meta.updated_at),
    } as WeatherData;
  }
}
