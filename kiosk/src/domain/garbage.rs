use std::collections::HashSet;

use chrono::{Datelike, Local, NaiveDate};
use iced::alignment;
use iced::widget::image::{self, Image};
use iced::widget::{column, container, row, text, Space};
use iced::{Color, Element, Length};

use crate::model::garbage::{TrashCategory, TrashScheduleEntry};
use crate::polling::PollingState;
use crate::theme;

fn format_relative_day(date: NaiveDate) -> String {
    let today = Local::now().date_naive();
    let tomorrow = today + chrono::Duration::days(1);
    let overmorrow = today + chrono::Duration::days(2);

    if date == today {
        "I dag".to_string()
    } else if date == tomorrow {
        "I morgen".to_string()
    } else if date == overmorrow {
        "Overimorgen".to_string()
    } else {
        let month = match date.month() {
            1 => "januar",
            2 => "februar",
            3 => "mars",
            4 => "april",
            5 => "mai",
            6 => "juni",
            7 => "juli",
            8 => "august",
            9 => "september",
            10 => "oktober",
            11 => "november",
            12 => "desember",
            _ => "",
        };
        format!("{} {}", month, date.day())
    }
}

fn trash_icons<'a, Message: 'a>(
    category: &TrashCategory,
    icon_width: f32,
) -> Element<'a, Message> {
    let paths = category.icon_paths();
    let icons: Vec<Element<'a, Message>> = paths
        .iter()
        .map(|p| {
            Image::new(image::Handle::from_path(*p))
                .width(icon_width)
                .into()
        })
        .collect();

    row(icons).into()
}

fn plan_list_view<'a, Message: 'a>(entries: &[TrashScheduleEntry]) -> Element<'a, Message> {
    let mut seen = HashSet::new();
    let unique_entries: Vec<&TrashScheduleEntry> = entries
        .iter()
        .filter(|e| seen.insert(e.category.clone()))
        .take(8)
        .collect();

    let rows: Vec<Element<'a, Message>> = unique_entries
        .iter()
        .map(|entry| {
            let icons = trash_icons(&entry.category, 64.0);
            let date_text = text(format_relative_day(entry.date))
                .size(24)
                .font(theme::FONT_INTER)
                .color(theme::TEXT_COLOR);
            let label = text(entry.category.label())
                .size(18)
                .font(theme::FONT_INTER)
                .color(theme::TEXT_COLOR);

            let right_col = column![date_text, label].align_x(alignment::Horizontal::Right);

            row![icons, Space::with_width(Length::Fill), right_col]
                .align_y(alignment::Vertical::Center)
                .into()
        })
        .collect();

    column(rows).spacing(12).into()
}

fn today_view<'a, Message: 'a>(
    entries: &[TrashScheduleEntry],
    title: &str,
) -> Element<'a, Message> {
    let title_text = text(title.to_string())
        .size(if entries.len() == 1 { 48 } else { 42 })
        .font(theme::FONT_INTER)
        .color(theme::TEXT_COLOR);

    let entry_views: Vec<Element<'a, Message>> = entries
        .iter()
        .map(|entry| {
            let icon_width = if entries.len() == 1 { 120.0 } else { 60.0 };
            let icons = trash_icons(&entry.category, icon_width);
            let label = text(entry.category.label())
                .size(32)
                .font(theme::FONT_INTER)
                .color(theme::TEXT_COLOR);

            if entries.len() == 1 {
                column![icons, label]
                    .align_x(alignment::Horizontal::Center)
                    .into()
            } else {
                row![icons, label]
                    .spacing(24)
                    .align_y(alignment::Vertical::Center)
                    .into()
            }
        })
        .collect();

    let mut content = column![title_text].align_x(alignment::Horizontal::Center);
    if entries.len() == 1 {
        content = content.spacing(24);
    } else {
        content = content.spacing(12);
    }
    for view in entry_views {
        content = content.push(view);
    }

    container(content)
        .center(Length::Fill)
        .into()
}

/// Returns the number of available sub-views for the current data
pub fn view_count(entries: &[TrashScheduleEntry]) -> usize {
    let today = Local::now().date_naive();
    let tomorrow = today + chrono::Duration::days(1);

    let mut count = 1; // plan list always shown
    if entries.iter().any(|e| e.date == today) {
        count += 1;
    }
    if entries.iter().any(|e| e.date == tomorrow) {
        count += 1;
    }
    count
}

pub fn view<'a, Message: 'a>(
    state: &PollingState<Vec<TrashScheduleEntry>>,
    view_index: usize,
) -> Element<'a, Message> {
    match state {
        PollingState::Initial => Space::new(Length::Fill, Length::Fill).into(),
        PollingState::Failure(msg) => container(
            text(msg.clone())
                .size(20)
                .color(Color::from_rgb(1.0, 0.0, 0.0)),
        )
        .center(Length::Fill)
        .into(),
        PollingState::Success(entries) => {
            let today = Local::now().date_naive();
            let tomorrow = today + chrono::Duration::days(1);

            let today_entries: Vec<TrashScheduleEntry> =
                entries.iter().filter(|e| e.date == today).cloned().collect();
            let tomorrow_entries: Vec<TrashScheduleEntry> = entries
                .iter()
                .filter(|e| e.date == tomorrow)
                .cloned()
                .collect();

            let mut views: Vec<Box<dyn Fn() -> Element<'a, Message>>> = vec![];
            views.push(Box::new(|| plan_list_view(entries)));
            if !today_entries.is_empty() {
                let te = today_entries.clone();
                views.push(Box::new(move || today_view(&te, "I dag")));
            }
            if !tomorrow_entries.is_empty() {
                let te = tomorrow_entries.clone();
                views.push(Box::new(move || today_view(&te, "I morgen")));
            }

            let idx = if views.is_empty() {
                0
            } else {
                view_index % views.len()
            };

            if let Some(view_fn) = views.get(idx) {
                view_fn()
            } else {
                plan_list_view(entries)
            }
        }
    }
}
