package com.project.artconnect.persistence;

import com.project.artconnect.dao.ArtistDao;
import com.project.artconnect.model.Artist;
import com.project.artconnect.model.Discipline;
import com.project.artconnect.util.ConnectionManager;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class JdbcArtistDao implements ArtistDao {

    private Artist mapRow(ResultSet rs) throws SQLException {
        Artist a = new Artist();
        a.setName(rs.getString("name"));
        a.setBio(rs.getString("bio"));
        a.setBirthYear(rs.getInt("birthYear"));
        a.setContactEmail(rs.getString("contactEmail"));
        a.setPhone(rs.getString("phone"));
        a.setCity(rs.getString("city"));
        a.setWebsite(rs.getString("website"));
        a.setSocialMedia(rs.getString("socialMedia"));
        a.setActive(rs.getBoolean("isActive"));
        return a;
    }

    @Override
    public List<Artist> findAll() {
        List<Artist> list = new ArrayList<>();
        String sql = "SELECT * FROM ARTIST";
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
    public void save(Artist a) {
        String sql = "INSERT INTO ARTIST (name, bio, birthYear, contactEmail, phone, city, website, socialMedia, isActive) VALUES (?,?,?,?,?,?,?,?,?)";
        try (Connection conn = ConnectionManager.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, a.getName());
            ps.setString(2, a.getBio());
            ps.setInt(3, a.getBirthYear() != null ? a.getBirthYear() : 0);
            ps.setString(4, a.getContactEmail());
            ps.setString(5, a.getPhone());
            ps.setString(6, a.getCity());
            ps.setString(7, a.getWebsite());
            ps.setString(8, a.getSocialMedia());
            ps.setBoolean(9, a.isActive());
            ps.executeUpdate();
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }

    @Override
    public void update(Artist a) {
        String sql = "UPDATE ARTIST SET bio=?, birthYear=?, contactEmail=?, phone=?, city=?, website=?, socialMedia=?, isActive=? WHERE name=?";
        try (Connection conn = ConnectionManager.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, a.getBio());
            ps.setInt(2, a.getBirthYear() != null ? a.getBirthYear() : 0);
            ps.setString(3, a.getContactEmail());
            ps.setString(4, a.getPhone());
            ps.setString(5, a.getCity());
            ps.setString(6, a.getWebsite());
            ps.setString(7, a.getSocialMedia());
            ps.setBoolean(8, a.isActive());
            ps.setString(9, a.getName());
            ps.executeUpdate();
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }

    @Override
    public void delete(String name) {
        String sql = "DELETE FROM ARTIST WHERE name=?";
        try (Connection conn = ConnectionManager.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, name);
            ps.executeUpdate();
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }

    @Override
    public List<Artist> findByCity(String city) {
        List<Artist> list = new ArrayList<>();
        String sql = "SELECT * FROM ARTIST WHERE city=?";
        try (Connection conn = ConnectionManager.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, city);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) list.add(mapRow(rs));
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }
}
