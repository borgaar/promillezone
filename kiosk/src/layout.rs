use iced::widget::{column, container, row, Container};
use iced::{Element, Length};

use crate::theme;

pub fn view(kiosk: &crate::Kiosk) -> Element<'_, crate::Message> {
    let time_widget = kiosk_container(crate::domain::time::view(&kiosk.now))
        .width(Length::FillPortion(1))
        .height(Length::Fill);

    let content_widget = kiosk_container(crate::domain::content::view(&kiosk.content))
        .width(Length::FillPortion(2))
        .height(Length::Fill);

    let top_row = row![time_widget, content_widget]
        .spacing(theme::CONTAINER_SPACING)
        .height(Length::FillPortion(2));

    let weather_widget = kiosk_container(crate::domain::weather::view(&kiosk.weather))
        .width(Length::FillPortion(3))
        .height(Length::Fill);

    let transport_widget = kiosk_container(crate::domain::transport::view(&kiosk.transport))
        .width(Length::FillPortion(6))
        .height(Length::Fill);

    let garbage_widget =
        kiosk_container(crate::domain::garbage::view(&kiosk.garbage, kiosk.garbage_view_index))
            .width(Length::Fill)
            .height(Length::Fill);

    let wifi_widget = kiosk_container(crate::domain::wifi::view(&kiosk.wifi_qr))
        .width(Length::Fill)
        .height(Length::Fixed(200.0));

    let right_sidebar = column![garbage_widget, wifi_widget]
        .spacing(theme::CONTAINER_SPACING)
        .width(Length::FillPortion(2));

    let bottom_row = row![weather_widget, transport_widget, right_sidebar]
        .spacing(theme::CONTAINER_SPACING)
        .height(Length::FillPortion(3));

    // Inner container at design resolution (1920x1080)
    let inner = container(
        column![top_row, bottom_row]
            .spacing(theme::CONTAINER_SPACING)
            .width(Length::Fill)
            .height(Length::Fill),
    )
    .padding(theme::CONTAINER_SPACING)
    .width(Length::Fixed(1920.0))
    .height(Length::Fixed(1080.0))
    .style(|_| container::Style {
        background: Some(iced::Background::Color(theme::PAGE_BACKGROUND_COLOR)),
        ..Default::default()
    });

    // Outer container for letterboxing (black bars)
    container(inner)
        .center(Length::Fill)
        .style(|_| container::Style {
            background: Some(iced::Background::Color(iced::Color::BLACK)),
            ..Default::default()
        })
        .into()
}

pub fn kiosk_container<'a>(
    content: impl Into<Element<'a, crate::Message>>,
) -> Container<'a, crate::Message> {
    container(content)
        .padding(16)
        .style(|_| container::Style {
            background: Some(iced::Background::Color(theme::BACKGROUND_COLOR)),
            border: iced::Border {
                radius: theme::BORDER_RADIUS.into(),
                ..Default::default()
            },
            ..Default::default()
        })
        .clip(true)
}
