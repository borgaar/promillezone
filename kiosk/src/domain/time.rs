use chrono::{DateTime, Datelike, Local, Timelike};
use iced::alignment;
use iced::widget::image::{self, Image};
use iced::widget::{column, container, row, stack, text};
use iced::{Color, Element, Length};

use crate::theme;

fn weekday_text(weekday: chrono::Weekday) -> &'static str {
    match weekday {
        chrono::Weekday::Mon => "Mandag >:(",
        chrono::Weekday::Tue => "Tirsdag :(",
        chrono::Weekday::Wed => "Onsdag :|",
        chrono::Weekday::Thu => "Torsdag :)",
        chrono::Weekday::Fri => "Fredag B)",
        chrono::Weekday::Sat => "Lørdag :D",
        chrono::Weekday::Sun => "Søndag :/",
    }
}

fn month_name(month: u32) -> &'static str {
    match month {
        1 => "Januar",
        2 => "Februar",
        3 => "Mars",
        4 => "April",
        5 => "Mai",
        6 => "Juni",
        7 => "Juli",
        8 => "August",
        9 => "September",
        10 => "Oktober",
        11 => "November",
        12 => "Desember",
        _ => "",
    }
}

fn month_image(month: u32) -> &'static str {
    match month {
        1 => "asset/img/months/january.png",
        2 => "asset/img/months/february.png",
        3 => "asset/img/months/march.png",
        4 => "asset/img/months/april.png",
        5 => "asset/img/months/may.png",
        6 => "asset/img/months/june.png",
        7 => "asset/img/months/july.png",
        8 => "asset/img/months/august.png",
        9 => "asset/img/months/september.png",
        10 => "asset/img/months/october.png",
        11 => "asset/img/months/november.png",
        12 => "asset/img/months/december.png",
        _ => "",
    }
}

pub fn view<'a, Message: 'a>(now: &DateTime<Local>) -> Element<'a, Message> {
    let clock = text(format!(
        "{:02}:{:02}:{:02}",
        now.hour(),
        now.minute(),
        now.second()
    ))
    .size(94)
    .font(theme::FONT_JETBRAINS_MONO)
    .color(theme::TEXT_COLOR);

    let weekday = text(weekday_text(now.weekday()))
        .size(72)
        .font(theme::FONT_INTER_EXTRABOLD)
        .color(theme::TEXT_COLOR);

    let day_number = stack![
        Image::new(image::Handle::from_path("asset/img/months/day.png"))
            .width(120)
            .height(120),
        container(
            text(now.day().to_string())
                .size(70)
                .font(theme::FONT_COMIC_NEUE)
                .color(Color::BLACK)
        )
        .width(120)
        .height(120)
        .align_x(alignment::Horizontal::Center)
        .align_y(alignment::Vertical::Bottom)
    ]
    .width(120)
    .height(120);

    let month_view = stack![
        Image::new(image::Handle::from_path(month_image(now.month())))
            .width(380),
        container(
            text(month_name(now.month()))
                .size(50)
                .font(theme::FONT_COMIC_NEUE)
                .color(Color::WHITE)
        )
        .center(Length::Fill)
    ];

    let date_row = row![day_number, month_view]
        .spacing(12)
        .align_y(alignment::Vertical::Center);

    column![clock, weekday, date_row]
        .padding(16)
        .width(Length::Fill)
        .align_x(alignment::Horizontal::Center)
        .into()
}
