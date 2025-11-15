package org.example.ptcmssbackend.repository;

import org.example.ptcmssbackend.entity.Notifications;
import org.springframework.data.jpa.repository.JpaRepository;

public interface NotificationRepository extends JpaRepository<Notifications, Integer> {
}