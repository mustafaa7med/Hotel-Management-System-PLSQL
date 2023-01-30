-- Creating a trigger to track room's availability in case a room was reserved
CREATE OR REPLACE TRIGGER room_registry_trg
AFTER INSERT ON room_reservation
REFERENCING NEW AS New OLD AS Old
FOR EACH ROW

BEGIN
    
    INSERT INTO room_registry VALUES(:Old.room_id, :Old.hotel_id, sysdate, 'booked');
    
END;

-- Creating a trigger to track room's availablility in case a room was cancelled

CREATE OR REPLACE TRIGGER cancel_room_registry_trg
AFTER DELETE ON room_reservation
REFERENCING NEW AS New OLD AS Old
FOR EACH ROW

BEGIN
    
    INSERT INTO room_registry VALUES(:Old.room_id, :Old.hotel_id, sysdate, 'available');
    
END;