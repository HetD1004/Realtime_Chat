import express from 'express';
import { 
  getChatRooms, 
  createChatRoom, 
  joinRoom, 
  leaveRoom, 
  getRoomMessages 
} from '../controllers/roomController';
import { authenticateToken } from '../middleware/auth';

const router = express.Router();

// All routes are protected
router.use(authenticateToken);

router.get('/', getChatRooms);
router.post('/', createChatRoom);
router.post('/:roomId/join', joinRoom);
router.post('/:roomId/leave', leaveRoom);
router.get('/:roomId/messages', getRoomMessages);

export default router;