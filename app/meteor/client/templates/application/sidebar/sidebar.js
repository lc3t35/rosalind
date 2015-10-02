const sidebar = [
  {
    name: 'inboundCalls.this',
    icon: 'phone',
    countBadge: 'inboundCalls',
    roles: ['admin', 'inboundCalls'],
    submenu: [
      { name: 'inboundCalls.thisOpen', link: '/inboundCalls' },
      { name: 'inboundCalls.thisResolved', link: '/inboundCalls/resolved' },
      { name: 'inboundCalls.new', link: '/inboundCalls/new' }
    ]
  },
  {
    name: 'schedules.this',
    icon: 'user-md',
    roles: ['admin', 'schedules'],
    submenu: [
      { name: 'schedules.thisCurrent', link: '/schedules' }
    ]
  },
  {
    name: 'users.this',
    icon: 'unlock-alt',
    roles: ['admin'],
    submenu: [
      { name: 'users.thisAll', link: '/users' },
      { name: 'users.thisNew', link: '/users/new' }
    ]
  }
];

Template.sidebar.helpers({
  sidebar() { return sidebar; },
  toHtmlId(name) { return TAPi18n.__(name).replace(/[^a-z]/ig, '-').toLowerCase(); },
  showNav(roles) {
    if (typeof roles === 'undefined') return true;
    if (roles && Roles.userIsInRole(Meteor.user(), roles)) return true;
    return false;
  }
});

Template.sidebar.events({
  'click .treeview-menu a'() {
    $('body').removeClass('sidebar-open');
  }
});
