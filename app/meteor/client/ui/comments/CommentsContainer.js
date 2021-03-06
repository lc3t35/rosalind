import { Comments } from 'api/comments'
import { CommentsBox } from './CommentsBox'
import { composeWithTracker } from 'react-komposer'

const commentsBoxComposer = (props, onData) => {
  const comments = Comments.find({ docId: props.docId }, { sort: { createdAt: 1 } }).fetch()
  onData(null, { comments, docId: props.docId })
}

export const CommentsContainer = composeWithTracker(commentsBoxComposer)(CommentsBox)
