package com.project.artconnect.persistence;

import com.project.artconnect.dao.ArtworkDao;
import com.project.artconnect.model.Artist;
import com.project.artconnect.model.Artwork;
import com.project.artconnect.util.ConnectionManager;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class JdbcArtworkDao implements ArtworkDao {

    private Artwork mapRow(ResultSet rs) throws SQLException {
        Artwork a = new Artwork();
        a.setTitle(rs.getString("title"));
        a.setCreationYear(rs.getInt("creationYear"));
        a.setType(rs.getString("type"));
        a.setMedium(rs.getString("medium"));
        a.setDimensions(rs.getString("dimensions"));
        a.setDescription(rs.getString("description"));
        a.setPrice(rs.getDouble("price"));
        a.setStatus(Artwork.Status.valueOf(rs.getString("status")));
        Artist artist = new Artist();
        artist.setName(rs.getString("artist_name"));
        a.setArtist(artist);
        return a;
    }

    @Override
    public List<Artwork> findAll() {
        List<Artwork> list = new ArrayList<>();
        String sql = "SELECT aw.*, ar.name AS artist_name FROM ARTWORK aw JOIN ARTIST ar ON aw.id_artist = ar.id_artist";
        try (Connection conn = ConnectionManager.getConnection();
             Statement stmt = conn.createStatement();
             ResultSet rs = stmt.executeQuery(sql)) {
            while (rs.next()) list.add(mapRow(rs));
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    @Override
    public void save(Artwork a) {
        String sqlArtist = "SELECT id_artist FROM ARTIST WHERE name=?";
        String sql = "INSERT INTO ARTWORK (title, creationYear, type, medium, dimensions, description, price, status, id_artist) VALUES (?,?,?,?,?,?,?,?,?)";
        try (Connection conn = ConnectionManager.getConnection()) {
            int artistId;
            try (PreparedStatement ps = conn.prepareStatement(sqlArtist)) {
                ps.setString(1, a.getArtist().getName());
                ResultSet rs = ps.executeQuery();
                if (!rs.next()) return;
                artistId = rs.getInt("id_artist");
            }
            try (PreparedStatement ps = conn.prepareStatement(sql)) {
                ps.setString(1, a.getTitle());
                ps.setInt(2, a.getCreationYear() != null ? a.getCreationYear() : 0);
                ps.setString(3, a.getType());
                ps.setString(4, a.getMedium());
                ps.setString(5, a.getDimensions());
                ps.setString(6, a.getDescription());
                ps.setDouble(7, a.getPrice());
                ps.setString(8, a.getStatus().name());
                ps.setInt(9, artistId);
                ps.executeUpdate();
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }

    @Override
    public void update(Artwork a) {
        String sql = "UPDATE ARTWORK SET creationYear=?, type=?, medium=?, dimensions=?, description=?, price=?, status=? WHERE title=?";
        try (Connection conn = ConnectionManager.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, a.getCreationYear() != null ? a.getCreationYear() : 0);
            ps.setString(2, a.getType());
            ps.setString(3, a.getMedium());
            ps.setString(4, a.getDimensions());
            ps.setString(5, a.getDescription());
            ps.setDouble(6, a.getPrice());
            ps.setString(7, a.getStatus().name());
            ps.setString(8, a.getTitle());
            ps.executeUpdate();
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }

    @Override
    public void delete(String title) {
        String sql = "DELETE FROM ARTWORK WHERE title=?";
        try (Connection conn = ConnectionManager.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, title);
            ps.executeUpdate();
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }

    @Override
    public List<Artwork> findByArtistName(String artistName) {
        List<Artwork> list = new ArrayList<>();
        String sql = "SELECT aw.*, ar.name AS artist_name FROM ARTWORK aw JOIN ARTIST ar ON aw.id_artist = ar.id_artist WHERE ar.name=?";
        try (Connection conn = ConnectionManager.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, artistName);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) list.add(mapRow(rs));
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }
}
