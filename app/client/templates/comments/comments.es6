Template.comments.helpers({
  commentCount() {
    return Comments.find({docId: this._id}).count({});
  }
});