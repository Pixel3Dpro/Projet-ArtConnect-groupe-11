package com.project.artconnect.ui;

import com.project.artconnect.model.Exhibition;
import com.project.artconnect.model.Workshop;
import com.project.artconnect.persistence.JdbcExhibitionDao;
import com.project.artconnect.service.WorkshopService;
import com.project.artconnect.util.ServiceProvider;
import javafx.fxml.FXML;
import javafx.geometry.Insets;
import javafx.scene.control.Label;
import javafx.scene.layout.FlowPane;
import javafx.scene.layout.VBox;
import java.util.List;

public class DiscoverController {
    @FXML
    private FlowPane discoverPane;

    private final JdbcExhibitionDao exhibitionDao = new JdbcExhibitionDao();
    private final WorkshopService workshopService = ServiceProvider.getWorkshopService();

    @FXML
    public void initialize() {
        List<Exhibition> featuredExhibitions = exhibitionDao.findAll();
        featuredExhibitions.stream().limit(3).forEach(this::addExhibitionCard);
        workshopService.getAllWorkshops().stream().limit(3).forEach(this::addWorkshopCard);
    }

    private void addExhibitionCard(Exhibition e) {
        VBox card = new VBox(5);
        card.setPadding(new Insets(10));
        card.setStyle("-fx-background-color: #e3f2fd; -fx-border-color: #2196f3; -fx-border-radius: 5; -fx-background-radius: 5;");
        card.setPrefWidth(250);
        card.getChildren().addAll(
                new Label("FEATURED EXHIBITION"),
                new Label(e.getTitle()) {{
                    setStyle("-fx-font-weight: bold;");
                }},
                new Label("Theme: " + e.getTheme()),
                new Label("Gallery: " + (e.getGallery() != null ? e.getGallery().getName() : "Unknown")));
        discoverPane.getChildren().add(card);
    }

    private void addWorkshopCard(Workshop w) {
        VBox card = new VBox(5);
        card.setPadding(new Insets(10));
        card.setStyle("-fx-background-color: #f1f8e9; -fx-border-color: #4caf50; -fx-border-radius: 5; -fx-background-radius: 5;");
        card.setPrefWidth(250);
        card.getChildren().addAll(
                new Label("UPCOMING WORKSHOP"),
                new Label(w.getTitle()) {{
                    setStyle("-fx-font-weight: bold;");
                }},
                new Label("Instructor: " + (w.getInstructor() != null ? w.getInstructor().getName() : "Unknown")),
                new Label("Price: $" + w.getPrice()));
        discoverPane.getChildren().add(card);
    }
}
