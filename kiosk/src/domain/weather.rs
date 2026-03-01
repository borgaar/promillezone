use chrono::Datelike;
use iced::alignment;
use iced::widget::image::{self, Image};
use iced::widget::{column, container, row, text, Space};
use iced::{Color, Element, Length};

use crate::model::weather::{Forecast, WeatherData};
use crate::polling::PollingState;
use crate::theme;

fn weekday_label(weekday: chrono::Weekday) -> &'static str {
    match weekday {
        chrono::Weekday::Mon => "mandag",
        chrono::Weekday::Tue => "tirsdag",
        chrono::Weekday::Wed => "onsdag",
        chrono::Weekday::Thu => "torsdag",
        chrono::Weekday::Fri => "fredag",
        chrono::Weekday::Sat => "lørdag",
        chrono::Weekday::Sun => "søndag",
    }
}

fn forecast_label(index: usize, forecast: &Forecast) -> String {
    match index {
        0 => "nå".to_string(),
        1 => "6t".to_string(),
        2 => "12t".to_string(),
        3 => "i morgen".to_string(),
        4 | 5 => weekday_label(forecast.time.weekday()).to_string(),
        _ => String::new(),
    }
}

fn temp_color(temp: i32) -> Color {
    if temp >= 20 {
        theme::TEMP_HOT
    } else if temp >= 1 {
        Color::WHITE
    } else {
        theme::TEMP_COLD
    }
}

fn precip_color(mm: i32) -> Color {
    if mm == 0 {
        theme::RAIN_NONE
    } else if mm <= 3 {
        theme::TEMP_COLD
    } else {
        theme::RAIN_HEAVY
    }
}

fn forecast_row<'a, Message: 'a>(label: &str, forecast: &Forecast) -> Element<'a, Message> {
    let label_text = text(label.to_string())
        .size(32)
        .font(theme::FONT_INTER_EXTRABOLD)
        .color(theme::TEXT_COLOR);

    let icon = Image::new(image::Handle::from_path(&forecast.icon_path))
        .width(92);

    let temp = text(format!("{}°", forecast.temperature))
        .size(42)
        .font(theme::FONT_INTER)
        .color(temp_color(forecast.temperature));

    let precip = row![
        text(forecast.precipitation_mm.to_string())
            .size(38)
            .font(theme::FONT_INTER)
            .color(precip_color(forecast.precipitation_mm)),
        text("mm")
            .size(24)
            .font(theme::FONT_INTER)
            .color(precip_color(forecast.precipitation_mm)),
    ]
    .align_y(alignment::Vertical::Bottom);

    let data_col = column![temp, precip];

    let right_group = row![icon, data_col]
        .spacing(8)
        .width(200)
        .align_y(alignment::Vertical::Center);

    container(
        row![label_text, Space::with_width(Length::Fill), right_group]
            .align_y(alignment::Vertical::Center),
    )
    .into()
}

pub fn view<'a, Message: 'a>(state: &PollingState<WeatherData>) -> Element<'a, Message> {
    match state {
        PollingState::Initial => Space::new(Length::Fill, Length::Fill).into(),
        PollingState::Failure(msg) => container(
            text(msg.clone())
                .size(20)
                .color(Color::from_rgb(1.0, 0.0, 0.0)),
        )
        .center(Length::Fill)
        .into(),
        PollingState::Success(data) => {
            let rows: Vec<Element<'a, Message>> = data
                .forecasts
                .iter()
                .enumerate()
                .take(6)
                .map(|(i, f)| {
                    let label = forecast_label(i, f);
                    forecast_row(&label, f)
                })
                .collect();

            column(rows)
                .spacing(6)
                .align_x(alignment::Horizontal::Center)
                .into()
        }
    }
}
