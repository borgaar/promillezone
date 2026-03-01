use chrono::Timelike;
use iced::alignment;
use iced::widget::image::{self, Image};
use iced::widget::{column, container, row, text, Space};
use iced::{Color, Element, Length};

use crate::model::transport::{Departure, StopPlace};
use crate::polling::PollingState;
use crate::theme;

fn status_text(minutes: i64) -> Option<&'static str> {
    match minutes {
        ..=5 => None, // skull emoji
        6 => Some("spurt"),
        7 => Some("løp"),
        8 => Some("jogg"),
        9 => Some("gå"),
        10 => Some("ferdig"),
        11 => Some("klar"),
        12 => Some("gucci"),
        _ => Some("chillern"),
    }
}

fn header_cell<'a, Message: 'a>(label: &str, portion: u16) -> Element<'a, Message> {
    container(
        text(label.to_string())
            .size(24)
            .font(theme::FONT_INTER_EXTRABOLD)
            .color(theme::TEXT_COLOR),
    )
    .width(Length::FillPortion(portion))
    .center_x(Length::Fill)
    .into()
}

fn departure_row<'a, Message: 'a>(dep: &Departure) -> Element<'a, Message> {
    let adjusted_minutes = dep.until_minutes + dep.time_padding();

    // Line badge
    let badge_color = if dep.is_fb_line {
        Color::from_rgb(0.5, 0.5, 0.5)
    } else {
        theme::TRANSPORT_LINE_GREEN
    };
    let badge = container(
        text(dep.line_code.clone())
            .size(32)
            .font(theme::FONT_INTER_EXTRABOLD)
            .color(Color::BLACK),
    )
    .style(move |_| iced::widget::container::Style {
        background: Some(iced::Background::Color(badge_color)),
        border: iced::Border {
            radius: 16.0.into(),
            ..Default::default()
        },
        ..Default::default()
    })
    .padding([8, 12])
    .center_x(Length::Fill);

    let badge_cell = container(badge).width(Length::FillPortion(3));

    // Destination (truncate to 24 chars)
    let mut dest = dep.destination.clone();
    if dest.len() > 24 {
        dest.truncate(21);
        dest.push_str("...");
    }
    let dest_cell = container(
        text(dest)
            .size(32)
            .font(theme::FONT_INTER)
            .color(theme::TEXT_COLOR),
    )
    .width(Length::FillPortion(8))
    .padding(iced::Padding { top: 0.0, right: 0.0, bottom: 0.0, left: 8.0 });

    // Platform
    let platform_cell = container(
        text(dep.platform.clone())
            .size(32)
            .font(theme::FONT_INTER)
            .color(theme::TEXT_COLOR),
    )
    .width(Length::FillPortion(2))
    .center_x(Length::Fill);

    // Status
    let status_cell: Element<'a, Message> = if adjusted_minutes <= 5 {
        container(
            Image::new(image::Handle::from_path("asset/img/skull_emoji.png")).height(32),
        )
        .width(Length::FillPortion(4))
        .center_x(Length::Fill)
        .into()
    } else {
        container(
            text(status_text(adjusted_minutes).unwrap_or(""))
                .size(24)
                .font(theme::FONT_INTER)
                .color(theme::TEXT_COLOR),
        )
        .width(Length::FillPortion(4))
        .center_x(Length::Fill)
        .into()
    };

    // Time until
    let (time_num, time_label) = if dep.until_minutes > 59 {
        let hours = dep.until_minutes / 60;
        let label = if hours == 1 { "time" } else { "timer" };
        (hours.to_string(), label)
    } else {
        (dep.until_minutes.to_string(), "min")
    };

    let time_cell = container(
        row![
            text(time_num)
                .size(32)
                .font(theme::FONT_INTER_EXTRABOLD)
                .color(theme::TEXT_COLOR),
            text(time_label)
                .size(16)
                .font(theme::FONT_INTER)
                .color(theme::TEXT_COLOR),
        ]
        .spacing(3)
        .align_y(alignment::Vertical::Bottom),
    )
    .width(Length::FillPortion(3));

    // Clock time
    let expected_str = format!("{:02}:{:02}", dep.expected_time.hour(), dep.expected_time.minute());
    let is_delayed = dep.is_delayed();
    let clock_color = if is_delayed {
        Color::from_rgb(0.9, 0.3, 0.25)
    } else {
        Color::WHITE
    };

    let mut clock_col = column![text(expected_str)
        .size(24)
        .font(theme::FONT_INTER)
        .color(clock_color)];

    if is_delayed {
        let aimed_str = format!("{:02}:{:02}", dep.aimed_time.hour(), dep.aimed_time.minute());
        clock_col = clock_col.push(
            text(aimed_str)
                .size(18)
                .font(theme::FONT_INTER)
                .color(theme::TEXT_COLOR),
        );
    }

    let clock_cell = container(clock_col).width(Length::FillPortion(3));

    row![
        badge_cell,
        dest_cell,
        platform_cell,
        status_cell,
        time_cell,
        clock_cell
    ]
    .align_y(alignment::Vertical::Center)
    .into()
}

pub fn view<'a, Message: 'a>(state: &PollingState<StopPlace>) -> Element<'a, Message> {
    match state {
        PollingState::Initial => Space::new(Length::Fill, Length::Fill).into(),
        PollingState::Failure(msg) => container(
            text(msg.clone())
                .size(20)
                .color(Color::from_rgb(1.0, 0.0, 0.0)),
        )
        .center(Length::Fill)
        .into(),
        PollingState::Success(stop) => {
            let filtered: Vec<&Departure> = stop
                .departures
                .iter()
                .filter(|d| d.until_minutes >= 5)
                .take(7)
                .collect();

            let header = row![
                header_cell("Nr.", 3),
                header_cell("Destinasjon", 8),
                header_cell("Plt.", 2),
                header_cell("Status", 4),
                header_cell("Tid", 3),
                header_cell("Kl.", 3),
            ];

            let mut content = column![header].spacing(12);

            for dep in filtered {
                content = content.push(departure_row(dep));
            }

            content
                .padding([theme::CONTAINER_PADDING_V, 0.0])
                .into()
        }
    }
}
