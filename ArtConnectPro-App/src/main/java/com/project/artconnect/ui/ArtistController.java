package com.project.artconnect.ui;

import com.project.artconnect.model.Artist;
import com.project.artconnect.model.Discipline;
import com.project.artconnect.service.ArtistService;
import com.project.artconnect.util.ServiceProvider;
import javafx.collections.FXCollections;
import javafx.fxml.FXML;
import javafx.scene.control.*;
import javafx.scene.control.cell.PropertyValueFactory;
import javafx.scene.layout.GridPane;
import javafx.geometry.Insets;
import java.util.Optional;

public class ArtistController {

    @FXML private TextField searchField;
    @FXML private ComboBox<Discipline> disciplineFilter;
    @FXML private TableView<Artist> artistTable;
    @FXML private TableColumn<Artist, String> nameColumn;
    @FXML private TableColumn<Artist, String> cityColumn;
    @FXML private TableColumn<Artist, String> emailColumn;
    @FXML private TableColumn<Artist, Integer> yearColumn;

    private final ArtistService artistService = ServiceProvider.getArtistService();

    @FXML
    public void initialize() {
        nameColumn.setCellValueFactory(new PropertyValueFactory<>("name"));
        cityColumn.setCellValueFactory(new PropertyValueFactory<>("city"));
        emailColumn.setCellValueFactory(new PropertyValueFactory<>("contactEmail"));
        yearColumn.setCellValueFactory(new PropertyValueFactory<>("birthYear"));

        disciplineFilter.setItems(FXCollections.observableArrayList(artistService.getAllDisciplines()));
        refreshTable();
    }


    //  RECHERCHE / RESET


    @FXML
    private void handleSearch() {
        String query = searchField.getText();
        Discipline d = disciplineFilter.getValue();
        String dName = (d != null) ? d.getName() : null;
        artistTable.setItems(FXCollections.observableArrayList(
            artistService.searchArtists(query, dName, null)));
    }

    @FXML
    private void handleReset() {
        searchField.clear();
        disciplineFilter.setValue(null);
        refreshTable();
    }


    //  DELETE


    @FXML
    private void handleDelete() {
        Artist selected = artistTable.getSelectionModel().getSelectedItem();

        // Aucune ligne sélectionnée
        if (selected == null) {
            showAlert(Alert.AlertType.WARNING,
                "Aucune sélection",
                "Veuillez sélectionner un artiste à supprimer.");
            return;
        }

        // Confirmation
        Alert confirm = new Alert(Alert.AlertType.CONFIRMATION);
        confirm.setTitle("Confirmer la suppression");
        confirm.setHeaderText("Supprimer \"" + selected.getName() + "\" ?");
        confirm.setContentText("Cette action est irréversible.");

        Optional<ButtonType> result = confirm.showAndWait();
        if (result.isPresent() && result.get() == ButtonType.OK) {
            artistService.deleteArtist(selected.getName());
            refreshTable();
        }
    }


    //  EDIT (UPDATE)


    @FXML
    private void handleEdit() {
        Artist selected = artistTable.getSelectionModel().getSelectedItem();

        if (selected == null) {
            showAlert(Alert.AlertType.WARNING,
                "Aucune sélection",
                "Veuillez sélectionner un artiste à modifier.");
            return;
        }

        // Formulaire dans une Dialog
        Dialog<Artist> dialog = new Dialog<>();
        dialog.setTitle("Modifier l'artiste");
        dialog.setHeaderText("Modification de : " + selected.getName());

        ButtonType saveBtn = new ButtonType("Enregistrer", ButtonBar.ButtonData.OK_DONE);
        dialog.getDialogPane().getButtonTypes().addAll(saveBtn, ButtonType.CANCEL);

        // Champs du formulaire pré-remplis
        TextField tfName     = new TextField(selected.getName());
        TextField tfCity     = new TextField(selected.getCity());
        TextField tfEmail    = new TextField(selected.getContactEmail());
        TextField tfPhone    = new TextField(selected.getPhone());
        TextField tfWebsite  = new TextField(selected.getWebsite());
        TextField tfYear     = new TextField(
            selected.getBirthYear() != null ? String.valueOf(selected.getBirthYear()) : "");
        TextArea  taBio      = new TextArea(selected.getBio());
        taBio.setPrefRowCount(3);
        CheckBox  cbActive   = new CheckBox("Actif");
        cbActive.setSelected(selected.isActive());

        GridPane grid = new GridPane();
        grid.setHgap(10);
        grid.setVgap(10);
        grid.setPadding(new Insets(20, 150, 10, 10));

        grid.add(new Label("Nom :"),       0, 0); grid.add(tfName,    1, 0);
        grid.add(new Label("Ville :"),     0, 1); grid.add(tfCity,    1, 1);
        grid.add(new Label("Email :"),     0, 2); grid.add(tfEmail,   1, 2);
        grid.add(new Label("Téléphone :"), 0, 3); grid.add(tfPhone,   1, 3);
        grid.add(new Label("Site web :"),  0, 4); grid.add(tfWebsite, 1, 4);
        grid.add(new Label("Année :"),     0, 5); grid.add(tfYear,    1, 5);
        grid.add(new Label("Bio :"),       0, 6); grid.add(taBio,     1, 6);
        grid.add(cbActive,                 1, 7);

        dialog.getDialogPane().setContent(grid);

        // Convertir le résultat en objet Artist
        dialog.setResultConverter(btn -> {
            if (btn == saveBtn) {
                Artist updated = new Artist();
                updated.setName(tfName.getText().trim());
                updated.setCity(tfCity.getText().trim());
                updated.setContactEmail(tfEmail.getText().trim());
                updated.setPhone(tfPhone.getText().trim());
                updated.setWebsite(tfWebsite.getText().trim());
                updated.setBio(taBio.getText().trim());
                updated.setActive(cbActive.isSelected());
                try {
                    updated.setBirthYear(Integer.parseInt(tfYear.getText().trim()));
                } catch (NumberFormatException e) {
                    updated.setBirthYear(0);
                }
                return updated;
            }
            return null;
        });

        Optional<Artist> result = dialog.showAndWait();
        result.ifPresent(updated -> {
            artistService.updateArtist(updated);
            refreshTable();
        });
    }


    //  UTILITAIRES


    private void refreshTable() {
        artistTable.setItems(FXCollections.observableArrayList(artistService.getAllArtists()));
    }

    private void showAlert(Alert.AlertType type, String title, String message) {
        Alert alert = new Alert(type);
        alert.setTitle(title);
        alert.setHeaderText(null);
        alert.setContentText(message);
        alert.showAndWait();
    }
}
